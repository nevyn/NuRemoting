#import "ClientController.h"
#import "NRStatsCell.h"
#import <ACEView/ACEView.h>

static NSColor *DarkGreen() {
	return [NSColor colorWithDeviceRed:0 green:.5 blue:0 alpha:1];
}

@interface ClientController () <ACEViewDelegate> {
    int oldPort;
    int reconnectCount;
    NSMutableArray *statSets;
    BOOL hasAutoshownStats;
}
@property(weak) IBOutlet NSDrawer *statsDrawer;
@property(weak) IBOutlet NSTableView *statsTable;
@property(assign) IBOutlet NSTextView *logOutput;  // NSTextView does not support weak
@property(assign) IBOutlet NSTextView *output;
@property(weak) IBOutlet ACEView *input;
@property(weak) IBOutlet TemplateController *templates;

@property (readwrite, strong) RemotingClient *client;
@property (copy) NSString *oldHost;
-(void)appendString:(NSString*)str color:(NSColor*)color italic:(BOOL)italic to:(NSTextView*)dest;
@end


@implementation ClientController

-(instancetype)initWithClient:(RemotingClient*)client
{
	if(![super initWithWindowNibName:@"ClientController"])
		return nil;
	
	self.client = client;
	self.client.delegate = self;
	self.window.title = client.name;
	statSets = [NSMutableArray new];
    
    [self.input setDelegate:self];
    [self.input setMode:ACEModeClojure];
    [self.input setTheme:ACEThemeXcode];
    [self.input setShowInvisibles:YES];
    
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

-(void)appendString:(NSString*)str color:(NSColor*)color italic:(BOOL)italic to:(NSTextView*)dest
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

-(void)remotingClientConnected:(RemotingClient*)client
{
	self.oldHost = client.socket.connectedHost;
	oldPort = client.socket.connectedPort;
	reconnectCount = 0;
	[self appendString:@"Connected" color:DarkGreen() italic:NO to:self.output];
}

-(void)remotingClient:(RemotingClient*)client willDisconnectWithError:(NSError*)err
{
	[self appendString:[NSString stringWithFormat:@"Error: %@", [err localizedDescription]] color:[NSColor redColor] italic:NO to:self.output];
}

-(void)remotingClientDisconnected:(RemotingClient*)client
{
	if(reconnectCount < 5) {
		[self appendString:@"Disconnected; reconnecting in 5…" color:[NSColor redColor] italic:NO to:self.output];
		[self performSelector:@selector(reconnect) withObject:nil afterDelay:5];
	} else {
		[self appendString:@"Permanently disconnected, type /reconnect to try again" color:[NSColor redColor] italic:NO to:self.output];
	}
}
-(void)remotingClient:(RemotingClient*)client receivedOutput:(NSString*)str withStatusCode:(int)code
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

		[self appendString:str color:color italic:YES to:self.logOutput];
		return;
	}
	[self appendString:str color:(code!=RemotingStatusOK)?[NSColor redColor]:[NSColor blackColor] italic:NO to:self.output];
}

-(void)remotingClient:(RemotingClient*)client receivedData:(NSData*)data
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if(result != NSFileHandlingPanelOKButton) return;
		[data writeToURL:savePanel.URL atomically:NO];
	}];
}

#pragma mark Commands

-(void)reconnect
{
	reconnectCount++;
	[self appendString:[NSString stringWithFormat:@"Reconnect try %d to %@…", reconnectCount, self.oldHost] color:[NSColor darkGrayColor] italic:YES to:self.output];
	
	NSError *err = nil;
	RemotingClient *cl = nil;
	if(self.oldHost)
		cl = [[RemotingClient alloc] initWithHost:self.oldHost port:oldPort error:&err];
	if(!cl) {
		NSString *error = @"No host to connect to; aborting";
		if(err) error = [NSString stringWithFormat:@"%@; aborting", [err localizedDescription]];
		[self appendString:error color:[NSColor redColor] italic:YES to:self.output];
	}
	self.client = cl;
	self.client.delegate = self;
}

-(IBAction)sendCommand:(id)sender
{
	NSMutableString *outputString = [[self.input string] mutableCopy];
	if([outputString isEqual:@"/reconnect"]) {
		[self reconnect];
		return;
	} else if([outputString isEqual:@"/stats"]) {
		[self.statsDrawer open];
		return;
	}
	
	NSRange r;
	while(r = [outputString rangeOfString:@"#require "], r.location != NSNotFound) {
		NSRange toNewline = [outputString rangeOfString:@"\n" options:0 range:NSMakeRange(r.location+r.length, outputString.length-r.location-r.length)];
		NSString *templateName = [outputString substringWithRange:NSMakeRange(r.location+r.length, toNewline.location-r.location-r.length)];
		[outputString replaceCharactersInRange:NSMakeRange(r.location, toNewline.location-r.location) withString:[self.templates contentsOfSnippetNamed:templateName]];
	}
	[self appendString:outputString color:[NSColor purpleColor] italic:YES to:self.output];
	[self.client sendCommand:outputString];
}

#pragma mark Stats
-(NRStats*)statsNamed:(NSString*)name
{
	for(NRStats *stats in statSets)
		if([stats.name isEqual:name]) return stats;
	NRStats *stats = [[NRStats alloc] initWithName:name];
	[[self mutableArrayValueForKey:@"statSets"] addObject:stats];
	return stats;
}

-(void)remotingClient:(RemotingClient *)client receivedPoint:(float)pt at:(NSTimeInterval)sinceRef inSet:(NSString *)datasetName
{
	[[self statsNamed:datasetName] addPoint:pt atTime:sinceRef];
	
	if(!hasAutoshownStats && self.statsDrawer.state == NSDrawerClosedState) {
		hasAutoshownStats = YES;
		[self.statsDrawer open];
	}
}

#pragma mark - ACEViewDelegate
- (void) textDidChange:(NSNotification *)notification
{
    NSLog(@"");
}
@end
