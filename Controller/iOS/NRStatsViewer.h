#import <UIKit/UIKit.h>

@class RemotingClient;
@interface NRStatsViewer : UITableViewController
-(id)initWithClient:(RemotingClient*)client;

-(void)addPoint:(float)pt at:(NSTimeInterval)sinceRef inSet:(NSString*)datasetName;

@end
