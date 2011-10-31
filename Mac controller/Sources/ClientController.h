#import <Cocoa/Cocoa.h>
#import "RemotingClient.h"
#import "TemplateController.h"

@interface ClientController : NSWindowController
<RemotingClientDelegate, NSTableViewDelegate, NSTableViewDataSource>
{
	RemotingClient *client;
	IBOutlet NSTextView *logOutput;
	IBOutlet NSTextView *output;
	IBOutlet NSTextView *input;
	NSString *oldHost; int oldPort;
	int reconnectCount;
	IBOutlet TemplateController *templates;
	NSDrawer *statsDrawer;
	NSTableView *statsTable;
	NSMutableArray *statSets;
	BOOL hasAutoshownStats;
}
@property(readonly,assign) IBOutlet NSDrawer *statsDrawer;
@property(readonly,assign) IBOutlet NSTableView *statsTable;

@property(readonly,retain) RemotingClient *client;

-(id)initWithClient:(RemotingClient*)client_;
-(IBAction)sendCommand:(id)sender;
@end
