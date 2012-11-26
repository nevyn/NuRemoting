#import "NRClientVC.h"
#import "RemotingClient.h"
#import "NRStatsViewer.h"
#import "LogViewer.h"

@interface NRClientVC () <RemotingClientDelegate>
@end

@implementation NRClientVC {
	RemotingClient *_client;
	LogViewer *_log;
	NRStatsViewer *_stats;
}
- (id)initWithClient:(RemotingClient*)client;
{
	if(!(self = [super init])) return nil;
	
	_client = [client retain];
    _client.loggingEnabled = YES;
    _client.statsEnabled = YES;
	_client.delegate = self;
	
	_stats = [[NRStatsViewer alloc] init];
	_log = [LogViewer new];
	
	self.viewControllers = [NSArray arrayWithObjects:
		_log,
		_stats,
	nil];
	
	self.title = client.name;
	
    return self;
}
-(void)dealloc;
{
	_client.delegate = nil;
	[_client release];
	[_stats release];
	[super dealloc];
}


#pragma mark RemotingDelegate
-(void)remotingClient:(RemotingClient*)client receivedOutput:(NSString*)output withStatusCode:(int)code;
{
	[_log writeLine:output withLevel:code-600];
}
/*-(void)remotingClient:(RemotingClient*)client receivedData:(NSData*)output;
{
	// receive and display modally if image?
}*/
-(void)remotingClient:(RemotingClient*)client receivedPoint:(float)pt at:(NSTimeInterval)sinceRef inSet:(NSString*)datasetName;
{
	[_stats addPoint:pt at:sinceRef inSet:datasetName];
}

-(void)remotingClientConnected:(RemotingClient*)client;
{
	[_log writeLine:@"Connected!" withLevel:4];
}
-(void)remotingClient:(RemotingClient*)client willDisconnectWithError:(NSError*)err;
{
	[_log writeLine:@"Error!" withLevel:4];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:err.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}
-(void)remotingClientDisconnected:(RemotingClient*)client;
{
	[_log writeLine:@"Disconnected!" withLevel:4];
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
