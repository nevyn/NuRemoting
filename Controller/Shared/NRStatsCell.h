#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#define TABLECELL UITableViewCell
#else
#import <Cocoa/Cocoa.h>
#define TABLECELL NSTableCellView
#endif

#import "NRStats.h"

@class CPTGraphHostingView, CPTXYGraph, CPTXYAxis;
@interface NRStatsCell : TABLECELL {
	CPTGraphHostingView *hostView;
	NRStats *_stats;
	CPTXYGraph *_graph;
	CPTXYAxis *_floatingY;
	NSTimeInterval latestTaggedPoint;
}
@property(nonatomic,strong) IBOutlet CPTGraphHostingView *hostView;
@property(nonatomic,strong) NRStats *stats;

@end
