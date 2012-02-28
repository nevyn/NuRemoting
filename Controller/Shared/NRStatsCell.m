#import "NRStatsCell.h"
#if TARGET_OS_IPHONE
#import "CorePlot-CocoaTouch.h"
#else
#import <CorePlot/CorePlot.h>
#endif

static NSString *const NRStatsPlotIdentifier = @"NRStatsPlot";

@interface NRStatsCell () <CPTScatterPlotDataSource, NRStatsDelegate> 
-(void)updateRanges;
@end

@implementation NRStatsCell
@synthesize stats = _stats, hostView;
#if TARGET_OS_IPHONE
-(id)init;
{
	if(!(self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"StatsCell"]))
        return nil;
	
	hostView = [[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 16, 320, 100-16)];
	[self addSubview:hostView];
	
	self.textLabel.font = [UIFont boldSystemFontOfSize:12];
    self.detailTextLabel.font = [UIFont systemFontOfSize:12];
    self.detailTextLabel.textAlignment = UITextAlignmentRight;
	
	[self awakeFromNib];
	
	return self;
}
-(void)layoutSubviews;
{
	self.textLabel.frame = CGRectMake(0, 0, 100, 16);
	self.detailTextLabel.frame = CGRectMake(self.frame.size.width-100, 0, 100, 16);
    hostView.frame = CGRectMake(0, 16, self.frame.size.width, self.frame.size.height-16);
}
#endif

-(void)awakeFromNib;
{
#if TARGET_OS_IPHONE
    _graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:hostView.bounds];
    hostView.userInteractionEnabled = NO;
#else
    _graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:NSRectToCGRect(hostView.bounds)];
#endif
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
	
	_floatingY = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame:CGRectZero];
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
-(void)dealloc;
{
    if(_stats.delegate == self)
	_stats.delegate = nil;
	[hostView release];
	[_stats release];
	[_graph release];
	[_floatingY release];
	[super dealloc];
}

-(void)prepareForReuse;
{
	[self setStats:nil];
}


-(void)setStats:(NRStats *)stats;
{
	if(stats == _stats) return;
    
    if(_stats.delegate == self)
        _stats.delegate = nil;
	[_stats release];
    
	_stats = [stats retain];
	_stats.delegate = self;
    
	if(!_stats) return;
	
#if TARGET_OS_IPHONE
	self.textLabel.text = stats.name;
    self.detailTextLabel.text = [stats.data.lastObject description];
#else
	self.textField.stringValue = stats.name;
#endif
	[_graph reloadData];
	[self updateRanges];
}
#if !TARGET_OS_IPHONE
-(void)setObjectValue:(id)objectValue;
{
	[self setStats:objectValue];

	[super setObjectValue:objectValue];
}
#endif

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
    
#if TARGET_OS_IPHONE
    self.detailTextLabel.text = [stats.data.lastObject description];
#endif
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
	
	CPTMutablePlotRange *yRange = [[plotSpace.yRange mutableCopy] autorelease];
    [yRange unionPlotRange:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(0)]]; // always include 0
	[yRange expandRangeByFactor:CPTDecimalFromDouble(1.5)];
    plotSpace.yRange = yRange;
	
	_floatingY.orthogonalCoordinateDecimal = plotSpace.xRange.location;
}
@end
