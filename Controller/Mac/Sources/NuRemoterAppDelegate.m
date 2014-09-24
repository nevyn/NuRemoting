#import "NuRemoterAppDelegate.h"
#import "RemotingClient.h"
#import "ClientController.h"

@interface NuRemoterAppDelegate() {
    NSNetServiceBrowser *browser;
    NSMutableArray *foundServices; // <NSNetService>
}
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *customConnectField;
@property (weak) IBOutlet NSTextField *customPortField;
@property (weak) IBOutlet NSTableView *tableView;
@end

@implementation NuRemoterAppDelegate

-(instancetype)init
{
	foundServices = [NSMutableArray new];
	browser = [NSNetServiceBrowser new];
	browser.delegate = self;
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[RemotingClient performSearchOnBrowser:browser];
	[self.tableView setTarget:self];
	[self.tableView setDoubleAction:@selector(connect:)];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
           didFindService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
	[[self mutableArrayValueForKey:@"foundServices"] addObject:aNetService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing
{
	[[self mutableArrayValueForKey:@"foundServices"] removeObject:aNetService];
}

-(IBAction)connect:(NSTableView*)sender
{
	NSInteger r = sender.selectedRow;
	if(r < 0 || r >= [foundServices count]) return;
	NSNetService *service = foundServices[r];
	service.delegate = self;
	[service resolveWithTimeout:5.0];
}

-(IBAction)customConnect:(id)sender
{
    NSString *host = [self.customConnectField stringValue];
    int port = [self.customPortField intValue];
    [[sender window] close];
    
    NSError *err = nil;
	RemotingClient *client = [[RemotingClient alloc] initWithHost:host port:port error:&err];
	if(!client) {
		[NSApp presentError:err];
		return;
	}

    // FIXME: Don't let the RemotingClient hold this reference through it's delegate property
	ClientController *controller = [(ClientController*)[ClientController alloc] initWithClient:client];
	[controller showWindow:nil];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
	NSError *err = nil;
    RemotingClient *client = [[RemotingClient alloc] initWithService:service error:&err];
	if(!client) {
		[NSApp presentError:err];
		return;
	}
	ClientController *controller = [(ClientController*)[ClientController alloc] initWithClient:client];
	[controller showWindow:nil];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSRunAlertPanel(@"Couldn't resolve", @"Sorry, couldn't resolve the domain of the instance you clicked.", @"Bummer", nil, nil);
}

@end
