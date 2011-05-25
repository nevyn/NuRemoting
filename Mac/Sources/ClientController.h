#import <Cocoa/Cocoa.h>
#import "RemotingClient.h"
#import "TemplateController.h"

@interface ClientController : NSWindowController
<RemotingClientDelegate>
{
	RemotingClient *client;
	IBOutlet NSTextView *logOutput;
	IBOutlet NSTextView *output;
	IBOutlet NSTextView *input;
	NSString *oldHost; int oldPort;
	int reconnectCount;
	IBOutlet TemplateController *templates;
}
@property (readonly, retain) RemotingClient *client;
-(id)initWithClient:(RemotingClient*)client_;
-(IBAction)sendCommand:(id)sender;
@end
