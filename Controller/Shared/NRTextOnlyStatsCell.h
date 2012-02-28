#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define TABLECELL UITableViewCell
#else
#import <Cocoa/Cocoa.h>
#define TABLECELL NSTableCellView
#endif

#import "NRStats.h"

@interface NRTextOnlyStatsCell : TABLECELL <NRStatsDelegate> {
    NRStats *_stats;
}
@property(nonatomic,retain) NRStats *stats;
@end
