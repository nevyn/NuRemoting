//
//  NRStatsCell.m
//  NuRemoter
//
//  Created by Joachim Bengtsson on 2011-10-31.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NRStatsCell.h"
#import <CorePlot/CorePlot.h>

static NSString *const NRStatsPlotIdentifier = @"NRStatsPlot";

@interface NRStatsCell () <CPTScatterPlotDataSource, NRStatsDelegate> 
-(void)updateRanges;
@end

@implementation NRStatsCell
@synthesize stats = _stats;
-(void)awakeFromNib;
{
    _graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:NSRectToCGRect(hostView.bounds)];
    hostView.hostedGraph = _graph;
	_graph.paddingTop = _graph.paddingRight = _graph.paddingBottom = _graph.paddingLeft = 0;
	
	// Plot
	CPTScatterPlot *dataSourceLinePlot = [[(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame:_graph.bounds] autorelease];
	dataSourceLinePlot.identifier = NRStatsPlotIdentifier;	
	dataSourceLinePlot.dataSource = self;
	
    CPTMutableTextStyle *font = [CPTMutableTextStyle textStyle];
	font.fontSize = 10;
	
	dataSourceLinePlot.labelTextStyle = font;
	dataSourceLinePlot.labelOffset = -1.0;

	
	[_graph addPlot:dataSourceLinePlot];
	
	// Grid lines
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.3];
	
	// Axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
	
    CPTXYAxis *x = axisSet.xAxis;
    x.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    x.majorGridLineStyle = majorGridLineStyle;
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	x.labelFormatter = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter] autorelease];
    x.labelOffset = -3;
	x.labelTextStyle = font;

    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.majorGridLineStyle = majorGridLineStyle;
    y.labelOffset = 10.0;
}
-(void)setStats:(NRStats *)stats;
{
	if(stats == _stats) return;
	_stats.delegate = nil;
	[_stats release];
	_stats = [stats retain];
	_stats.delegate = self;
	if(!_stats) return;
	
	self.textField.stringValue = stats.name;
	[_graph reloadData];
	[self updateRanges];
}
-(void)setObjectValue:(id)objectValue;
{
	[self setStats:objectValue];
	[super setObjectValue:objectValue];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	return _stats.data.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index;
{
	if(fieldEnum == CPTScatterPlotFieldX) {
		return [_stats.times objectAtIndex:index];
	} else if(fieldEnum == CPTScatterPlotFieldY) {
		return [_stats.data objectAtIndex:index];
	}
	return nil;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index;
{
	int m = _stats.data.count / 6; if(m == 0) m = 1;
	if(index%m == 0) return nil;
	return (id)[NSNull null];
}

-(void)stats:(NRStats *)stats addedPoint:(float)pt at:(NSTimeInterval)when;
{
	CPTPlot *plot = [_graph plotWithIdentifier:NRStatsPlotIdentifier];
	if(_stats.data.count == plot.cachedDataCount+1)
		[plot insertDataAtIndex:_stats.data.count-1 numberOfRecords:1];
		
	[self updateRanges];
}
-(void)stats:(NRStats *)stats prunedPoints:(NSUInteger)deletedCount;
{
	CPTPlot *plot = [_graph plotWithIdentifier:NRStatsPlotIdentifier];
	[plot deleteDataInIndexRange:NSMakeRange(0, deletedCount)];
}
-(void)updateRanges;
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
	CPTPlot *dataSourceLinePlot = [_graph plotWithIdentifier:NRStatsPlotIdentifier];
    [plotSpace scaleToFitPlots:[NSArray arrayWithObject:dataSourceLinePlot]];
	
	CPTPlotRange *yRange = plotSpace.yRange;
    [yRange unionPlotRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-.5) length:CPTDecimalFromDouble(1)]]; // always include 0
	[yRange expandRangeByFactor:CPTDecimalFromDouble(1.1)];
    plotSpace.yRange = yRange;
	
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
	
    CPTXYAxis *y = axisSet.yAxis;
	y.labelOffset = CPTDecimalDoubleValue(plotSpace.xRange.end);
}
@end
