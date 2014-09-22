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
	NSDrawer *__weak statsDrawer;
	NSTableView *__weak statsTable;
	NSMutableArray *statSets;
	BOOL hasAutoshownStats;
}
@property(readonly,weak) IBOutlet NSDrawer *statsDrawer;
@property(readonly,weak) IBOutlet NSTableView *statsTable;

@property(readonly,strong) RemotingClient *client;

-(instancetype)initWithClient:(RemotingClient*)client_ NS_DESIGNATED_INITIALIZER;
-(IBAction)sendCommand:(id)sender;
@end
