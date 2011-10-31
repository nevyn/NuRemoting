//
//  NRStatsCell.h
//  NuRemoter
//
//  Created by Joachim Bengtsson on 2011-10-31.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NRStats.h"

@class CPTGraphHostingView, CPTXYGraph;
@interface NRStatsCell : NSTableCellView {
	IBOutlet CPTGraphHostingView *hostView;
	NRStats *_stats;
	CPTXYGraph *_graph;
	NSTimeInterval latestTaggedPoint;
}
@property(nonatomic,retain) NRStats *stats;

@end
