#import <Cocoa/Cocoa.h>
#import "RemotingClient.h"
#import "TemplateController.h"

@interface ClientController : NSWindowController
<RemotingClientDelegate, NSTableViewDelegate, NSTableViewDataSource>
@property(readonly,weak) IBOutlet NSDrawer *statsDrawer;
@property(readonly,weak) IBOutlet NSTableView *statsTable;

@property(readonly,strong) RemotingClient *client;

-(instancetype)initWithClient:(RemotingClient*)client_ NS_DESIGNATED_INITIALIZER;
-(IBAction)sendCommand:(id)sender;
@end
