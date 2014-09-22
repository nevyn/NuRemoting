#import "ClientController.h"
#import "NRStatsCell.h"

static NSColor *DarkGreen() {
	return [NSColor colorWithDeviceRed:0 green:.5 blue:0 alpha:1];
}

@interface ClientController () {
    RemotingClient *client;
    IBOutlet NSTextView *logOutput;
    IBOutlet NSTextView *output;
    IBOutlet NSTextView *input;
    NSString *oldHost; int oldPort;
    int reconnectCount;
    IBOutlet TemplateController *templates;
    NSDrawer *__weak statsDrawer;
    NSTableView *__weak statsTable;
    NSMutableArray *statSets;
    BOOL hasAutoshownStats;
}
@property (readwrite, strong) RemotingClient *client;
@property (copy) NSString *oldHost;
-(void)appendString:(NSString*)str color:(NSColor*)color italic:(BOOL)italic to:(NSTextView*)dest;
@end


@implementation ClientController
@synthesize client, oldHost, statsDrawer, statsTable;

-(instancetype)initWithClient:(RemotingClient*)client_;
{
	if(![super initWithWindowNibName:@"ClientController"])
		return nil;
	
	self.client = client_;
	self.client.delegate = self;
	self.window.title = client_.name;
	statSets = [NSMutableArray new];
	
	return self;
}

#pragma mark Text stuff

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
{
	if(commandSelector == @selector(insertNewlineIgnoringFieldEditor:)) {
		[self sendCommand:textView];
		return YES;
	}
	return NO;
}

-(void)appendString:(NSString*)str color:(NSColor*)color italic:(BOOL)italic to:(NSTextView*)dest;
{
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	if(italic) {
		NSFont *italic = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:12] toHaveTrait:NSItalicFontMask];
		attrs[NSFontAttributeName] = italic;
	}
	attrs[NSForegroundColorAttributeName] = color;
	NSAttributedString * astr = [[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"\n"] attributes:attrs];
	
	NSScrollView *scroll = [dest enclosingScrollView];
	BOOL scrollToEnd = [[scroll verticalScroller] floatValue] == 1 && dest.selectedRange.length==0;
	
	[[dest textStorage] appendAttributedString:astr];
	if(scrollToEnd) [dest scrollToEndOfDocument:nil];
}


#pragma mark RemotingClient delegate

-(void)remotingClientConnected:(RemotingClient*)client_;
{
	self.oldHost = client_.socket.connectedHost;
	oldPort = client_.socket.connectedPort;
	reconnectCount = 0;
	[self appendString:@"Connected" color:DarkGreen() italic:NO to:output];
}
-(void)remotingClient:(RemotingClient*)client willDisconnectWithError:(NSError*)err;
{
	[self appendString:[NSString stringWithFormat:@"Error: %@", [err localizedDescription]] color:[NSColor redColor] italic:NO to:output];
}
-(void)remotingClientDisconnected:(RemotingClient*)client;
{
	if(reconnectCount < 5) {
		[self appendString:@"Disconnected; reconnecting in 5…" color:[NSColor redColor] italic:NO to:output];
		[self performSelector:@selector(reconnect) withObject:nil afterDelay:5];
	} else {
		[self appendString:@"Permanently disconnected, type /reconnect to try again" color:[NSColor redColor] italic:NO to:output];
	}
}
-(void)remotingClient:(RemotingClient*)client receivedOutput:(NSString*)str withStatusCode:(int)code;
{
	if(code >= 600 && code < 700) {
		int level = code-600;
		
		NSColor *color = [NSColor blackColor];
		if(level < 3) // error, assert, fatal
			color = [NSColor redColor];
		else if(level == 3) // warning
			color = [NSColor colorWithCalibratedHue:.765 saturation:.7 brightness:1 alpha:1];
		else if(level == 4) // info
			color = [NSColor colorWithCalibratedHue:.68 saturation:.74 brightness:.8 alpha:1];
		else if(level == 5) // spam
			color = [NSColor brownColor];
		else if(level == 6) // debug0
			color = [NSColor colorWithCalibratedHue:.3 saturation:.5 brightness:.7 alpha:1];
		else if(level > 6) // debug1-7
			color = [NSColor colorWithCalibratedHue:.3 saturation:.5-((level-6)/7./2.) brightness:.7 alpha:1];

		[self appendString:str color:color italic:YES to:logOutput];
		return;
	}
	[self appendString:str color:(code!=RemotingStatusOK)?[NSColor redColor]:[NSColor blackColor] italic:NO to:output];
}
-(void)remotingClient:(RemotingClient*)client receivedData:(NSData*)data;
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if(result != NSFileHandlingPanelOKButton) return;
		[data writeToURL:savePanel.URL atomically:NO];
	}];
}

#pragma mark Commands

-(void)reconnect;
{
	reconnectCount++;
	[self appendString:[NSString stringWithFormat:@"Reconnect try %d to %@…", reconnectCount, self.oldHost] color:[NSColor darkGrayColor] italic:YES to:output];
	
	NSError *err = nil;
	RemotingClient *cl = nil;
	if(oldHost)
		cl = [[RemotingClient alloc] initWithHost:self.oldHost port:oldPort error:&err];
	if(!cl) {
		NSString *error = @"No host to connect to; aborting";
		if(err) error = [NSString stringWithFormat:@"%@; aborting", [err localizedDescription]];
		[self appendString:error color:[NSColor redColor] italic:YES to:output];
	}
	self.client = cl;
	self.client.delegate = self;
}

-(IBAction)sendCommand:(id)sender;
{
	NSMutableString *outputString = [[input string] mutableCopy];
	if([outputString isEqual:@"/reconnect"]) {
		[self reconnect];
		return;
	} else if([outputString isEqual:@"/stats"]) {
		[statsDrawer open];
		return;
	}
	
	NSRange r;
	while(r = [outputString rangeOfString:@"#require "], r.location != NSNotFound) {
		NSRange toNewline = [outputString rangeOfString:@"\n" options:0 range:NSMakeRange(r.location+r.length, outputString.length-r.location-r.length)];
		NSString *templateName = [outputString substringWithRange:NSMakeRange(r.location+r.length, toNewline.location-r.location-r.length)];
		[outputString replaceCharactersInRange:NSMakeRange(r.location, toNewline.location-r.location) withString:[templates contentsOfSnippetNamed:templateName]];
	}
	[self appendString:outputString color:[NSColor purpleColor] italic:YES to:output];
	[client sendCommand:outputString];
}

#pragma mark Stats
-(NRStats*)statsNamed:(NSString*)name;
{
	for(NRStats *stats in statSets)
		if([stats.name isEqual:name]) return stats;
	NRStats *stats = [[NRStats alloc] initWithName:name];
	[[self mutableArrayValueForKey:@"statSets"] addObject:stats];
	return stats;
}
-(void)remotingClient:(RemotingClient *)client receivedPoint:(float)pt at:(NSTimeInterval)sinceRef inSet:(NSString *)datasetName;
{
	[[self statsNamed:datasetName] addPoint:pt atTime:sinceRef];
	
	if(!hasAutoshownStats && statsDrawer.state == NSDrawerClosedState) {
		hasAutoshownStats = YES;
		[statsDrawer open];
	}
}
@end
