#import <UIKit/UIKit.h>

@interface NRStatsViewer : UITableViewController
-(id)init;

-(void)addPoint:(float)pt at:(NSTimeInterval)sinceRef inSet:(NSString*)datasetName;

@end
