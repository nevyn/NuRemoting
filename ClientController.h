#import <Cocoa/Cocoa.h>
#import "RemotingClient.h"


@interface ClientController : NSWindowController
<RemotingClientDelegate>
{
	RemotingClient *client;
	IBOutlet NSTextView *output;
	IBOutlet NSTextView *input;
}
@property (readonly, retain) RemotingClient *client;
-(id)initWithClient:(RemotingClient*)client_;
-(IBAction)sendCommand:(id)sender;
@end
