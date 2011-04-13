#import "ClientController.h"

static NSColor *DarkGreen() {
	return [NSColor colorWithDeviceRed:0 green:.5 blue:0 alpha:1];
}

@interface ClientController ()
@property (readwrite, retain) RemotingClient *client;
@property (copy) NSString *oldHost;
-(void)appendString:(NSString*)str color:(NSColor*)color italic:(BOOL)italic;
@end


@implementation ClientController
@synthesize client, oldHost;

-(id)initWithClient:(RemotingClient*)client_;
{
	if(![super initWithWindowNibName:@"ClientController"])
		return nil;
	
	self.client = client_;
	self.client.delegate = self;
	self.window.title = client_.name;
	
	
	return self;
}
-(void)dealloc;
{
	self.client = nil;
	self.oldHost = nil;
	[super dealloc];
}
-(void)reconnect;
{
	reconnectCount++;
	[self appendString:[NSString stringWithFormat:@"Reconnect try %d to %@…", reconnectCount, self.oldHost] color:[NSColor darkGrayColor] italic:YES];
	
	NSError *err = nil;
	RemotingClient *cl = nil;
	if(oldHost)
		cl = [[[RemotingClient alloc] initWithHost:self.oldHost port:oldPort error:&err] autorelease];
	if(!cl) {
		NSString *error = @"No host to connect to; aborting";
		if(err) error = [NSString stringWithFormat:@"%@; aborting", [err localizedDescription]];
		[self appendString:error color:[NSColor redColor] italic:YES];
	}
	self.client = cl;
	self.client.delegate = self;
}

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
{
	if(commandSelector == @selector(insertNewlineIgnoringFieldEditor:)) {
		[self sendCommand:textView];
		return YES;
	}
	return NO;
}

-(void)appendString:(NSString*)str color:(NSColor*)color italic:(BOOL)italic;
{
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
	if(italic) {
		NSFont *italic = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:12] toHaveTrait:NSItalicFontMask];
		[attrs setObject:italic forKey:NSFontAttributeName];
	}
	[attrs setObject:color forKey:NSForegroundColorAttributeName];
	NSAttributedString * astr = [[[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"\n"] attributes:attrs] autorelease];
	
	BOOL scrollToEnd = [[[output enclosingScrollView] verticalScroller] floatValue] > .99 && output.selectedRange.length==0;
	
	[[output textStorage] appendAttributedString:astr];
	
	if(scrollToEnd) [output scrollRangeToVisible:NSMakeRange([output textStorage].length, 0)];
}
-(void)remotingClientConnected:(RemotingClient*)client_;
{
	self.oldHost = client_.socket.connectedHost;
	oldPort = client_.socket.connectedPort;
	reconnectCount = 0;
	[self appendString:@"Connected" color:DarkGreen() italic:NO];
}
-(void)remotingClient:(RemotingClient*)client willDisconnectWithError:(NSError*)err;
{
	[self appendString:[NSString stringWithFormat:@"Error: %@", [err localizedDescription]] color:[NSColor redColor] italic:NO];
}
-(void)remotingClientDisconnected:(RemotingClient*)client;
{
	if(reconnectCount < 5) {
		[self appendString:@"Disconnected; reconnecting in 5…" color:[NSColor redColor] italic:NO];
		[self performSelector:@selector(reconnect) withObject:nil afterDelay:5];
	} else {
		[self appendString:@"Permanently disconnected, type /reconnect to try again" color:[NSColor redColor] italic:NO];
	}
}
-(void)remotingClient:(RemotingClient*)client receivedOutput:(NSString*)str withStatusCode:(int)code;
{
	if(code >= 600 && code < 700) {
		int level = code-600;
		
		NSColor *color = nil;
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

		[self appendString:str color:color italic:YES];
		return;
	}
	[self appendString:str color:(code!=RemotingStatusOK)?[NSColor redColor]:[NSColor blackColor] italic:NO];
}
-(void)remotingClient:(RemotingClient*)client receivedData:(NSData*)data;
{
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if(result != NSFileHandlingPanelOKButton) return;
		[data writeToURL:savePanel.URL atomically:NO];
	}];
}
-(IBAction)sendCommand:(id)sender;
{
	NSMutableString *outputString = [[[input string] mutableCopy] autorelease];
	if([outputString isEqual:@"/reconnect"]) {
		[self reconnect];
		return;
	}
	NSRange r;
	while(r = [outputString rangeOfString:@"#require "], r.location != NSNotFound) {
		NSRange toNewline = [outputString rangeOfString:@"\n" options:0 range:NSMakeRange(r.location+r.length, outputString.length-r.location-r.length)];
		NSString *templateName = [outputString substringWithRange:NSMakeRange(r.location+r.length, toNewline.location-r.location-r.length)];
		[outputString replaceCharactersInRange:NSMakeRange(r.location, toNewline.location-r.location) withString:[templates contentsOfSnippetNamed:templateName]];
	}
	[self appendString:outputString color:[NSColor purpleColor] italic:YES];
	[client sendCommand:outputString];
}
@end
