#import "NuRemoterAppDelegate.h"
#import "RemotingClient.h"
#import "ClientController.h"

@implementation NuRemoterAppDelegate

@synthesize window;
-(id)init;
{
	foundServices = [NSMutableArray new];
	browser = [NSNetServiceBrowser new];
	browser.delegate = self;
	return self;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[RemotingClient performSearchOnBrowser:browser];
	[tableView setTarget:self];
	[tableView setDoubleAction:@selector(connect:)];
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[[self mutableArrayValueForKey:@"foundServices"] addObject:aNetService];
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[[self mutableArrayValueForKey:@"foundServices"] removeObject:aNetService];
}

-(IBAction)connect:(NSTableView*)sender;
{
	NSInteger r = sender.selectedRow;
	if(r < 0 || r >= [foundServices count]) return;
	NSNetService *service = [foundServices objectAtIndex:r];
	service.delegate = self;
	[service resolveWithTimeout:5.0];
}
- (void)netServiceDidResolveAddress:(NSNetService *)service;
{
	RemotingClient *client = [[[RemotingClient alloc] initWithService:service] autorelease];
	ClientController *controller = [(ClientController*)[ClientController alloc] initWithClient:client];
	[controller showWindow:nil];
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
{
	NSRunAlertPanel(@"Couldn't resolve", @"Sorry, couldn't resolve the domain of the instance you clicked.", @"Bummer", nil, nil);
}



@end
