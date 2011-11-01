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
	
	//dataSourceLinePlot.labelTextStyle = font;
	//dataSourceLinePlot.labelOffset = -1.0;

	
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
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.majorGridLineStyle = majorGridLineStyle;
	
	_floatingY = [[(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame:CGRectZero] autorelease];
    _floatingY.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    _floatingY.labelOffset = -50.;
    _floatingY.coordinate = CPTCoordinateY;
    _floatingY.plotSpace = _graph.defaultPlotSpace;
	_floatingY.orthogonalCoordinateDecimal = CPTDecimalFromDouble(10);
	NSNumberFormatter *sciFormatter = [[NSNumberFormatter new] autorelease];
	sciFormatter.numberStyle = NSNumberFormatterScientificStyle;
	_floatingY.labelFormatter = sciFormatter;
	_floatingY.labelTextStyle = font;
	_floatingY.labelExclusionRanges = [NSArray arrayWithObject:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.01) length:CPTDecimalFromDouble(0.02)]];
	
	_graph.axisSet.axes = [NSArray arrayWithObjects:x, y, _floatingY, nil];
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
/* Can't come up with a way to make this look good, so y2 will have to do
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index;
{
	NSTimeInterval current = [[_stats.times objectAtIndex:index] doubleValue];
	if(current > latestTaggedPoint + 5) {
		latestTaggedPoint = current;
		return nil;
	}
	return (id)[NSNull null];
}*/

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
    [yRange unionPlotRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(0)]]; // always include 0
	[yRange expandRangeByFactor:CPTDecimalFromDouble(1.5)];
    plotSpace.yRange = yRange;
	
	_floatingY.orthogonalCoordinateDecimal = plotSpace.xRange.location;
}
@end
