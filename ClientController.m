#import "ClientController.h"


@interface ClientController ()
@property (readwrite, retain) RemotingClient *client;
@end


@implementation ClientController
@synthesize client;

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
	[super dealloc];
}

- (BOOL)textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector;
{
	if(commandSelector == @selector(insertNewlineIgnoringFieldEditor:)) {
		[self sendCommand:textView];
		return YES;
	}
	return NO;
}

-(void)remotingClientDisconnected:(RemotingClient*)client;
{
	[input setEditable:NO];
	[[input textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:@"Disconnected"] autorelease]];
}
-(void)remotingClient:(RemotingClient*)client receivedOutput:(NSString*)str withStatusCode:(int)code;
{
	NSColor *color = [NSColor blackColor];
	if(code != RemotingStatusOK)
		color = [NSColor redColor];
	NSAttributedString * astr = [[[NSAttributedString alloc] initWithString:[str stringByAppendingString:@"\n"] attributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName]] autorelease];
	
	[[output textStorage] appendAttributedString:astr];
	[output scrollRangeToVisible:NSMakeRange([output textStorage].length, 0)];
}
-(IBAction)sendCommand:(id)sender;
{
	NSString *outputString = [sender string];
	
	NSFont *italic = [[NSFontManager sharedFontManager] convertFont:[NSFont systemFontOfSize:12] toHaveTrait:NSItalicFontMask];
	NSAttributedString * astr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"> %@\n", outputString] attributes:[NSDictionary dictionaryWithObjectsAndKeys:[NSColor grayColor], NSForegroundColorAttributeName, italic, NSFontAttributeName, nil ]] autorelease];
	
	[[output textStorage] appendAttributedString:astr];
	[output scrollRangeToVisible:NSMakeRange([output textStorage].length, 0)];
	[client sendCommand:outputString];
}
@end
