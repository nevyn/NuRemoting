#import "NRHostFinder.h"
#import "RemotingClient.h"
#import "NRClientVC.h"

@interface NRHostFinder () <NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@end

@implementation NRHostFinder {
	NSNetServiceBrowser *browser;
	NSMutableArray *foundServices; // <NSNetService>
}

- (id)init;
{
	if(!(self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])) return nil;
	
	self.title = @"NuRemoter";
	
	foundServices = [NSMutableArray new];
	browser = [NSNetServiceBrowser new];
	browser.delegate = self;
	[RemotingClient performSearchOnBrowser:browser];
    return self;
}

-(void)viewDidAppear:(BOOL)animated;
{
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
}

#pragma mark NSNetService
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[[self mutableArrayValueForKey:@"foundServices"] addObject:aNetService];
	[self.tableView reloadData];
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
{
	[[self mutableArrayValueForKey:@"foundServices"] removeObject:aNetService];
	[self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSNetService *service = [foundServices objectAtIndex:indexPath.row];
	service.delegate = self;
	[service resolveWithTimeout:5.0];
}
- (void)netServiceDidResolveAddress:(NSNetService *)service;
{
	NSError *err = nil;
	RemotingClient *client = [[[RemotingClient alloc] initWithService:service error:&err] autorelease];
	if(!client) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error when connecting" message:err.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
	NRClientVC *inside = [[NRClientVC alloc] initWithClient:client];
	[self.navigationController pushViewController:inside animated:YES];
}
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't resolve" message:@"Sorry, couldn't resolve the domain of the instance you tapped." delegate:nil cancelButtonTitle:@"Bummer" otherButtonTitles:nil];
	[alert show];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return foundServices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HostCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[foundServices objectAtIndex:indexPath.row] name];
    
    return cell;
}

@end
