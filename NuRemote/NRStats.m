#import "NRStats.h"

@interface NRDescFormatter : NSFormatter
@end
@interface NRByteSizeFormatter : NSFormatter
@end


@interface NRStats ()
@property(nonatomic,copy,readwrite) NSString *name;
@property(nonatomic,strong,readwrite) NSMutableArray *times, *data;
@end

@implementation NRStats

-(instancetype)initWithName:(NSString*)name
{
	if(!(self = [super init])) return nil;
	
	self.name = name;
	_times = [NSMutableArray new];
	_data = [NSMutableArray new];
	_maximumDataAge = 60;
	_timeGranuality = 0.05;
    if([name rangeOfString:@"memory"].location != NSNotFound)
        _formatter = [NRByteSizeFormatter new];
    else
        _formatter = [NRDescFormatter new];
	
	return self;
}

-(void)addPoint:(float)point atTime:(NSTimeInterval)interval
{
	NSTimeInterval latest = [[_times lastObject] doubleValue];
	if(interval - latest < _timeGranuality) return;
	
	[_times addObject:@(interval)];
	[_data addObject:@(point)];
	[_delegate stats:self addedPoint:point at:interval];
	
	NSTimeInterval oldestAllowed = interval - _maximumDataAge;
	int numDeletedPoints = 0;
	while([_times[0] doubleValue] < oldestAllowed) {
		[_times removeObjectAtIndex:0];
		[_data removeObjectAtIndex:0];
		numDeletedPoints++;
	}
	if(numDeletedPoints > 0)
		[_delegate stats:self prunedPoints:numDeletedPoints];
}

-(NSDictionary*)dictionaryRepresentation
{
	NSMutableDictionary *d = [[NSMutableDictionary alloc] initWithCapacity:_data.count];
	for(int i = 0, c = _data.count; i < c; i++)
		d[_times[i]] = _data[i];
	return d;
}
@end


@implementation NRDescFormatter
-(NSString*)stringForObjectValue:(id)obj
{
    return [obj description];
}
@end


@implementation NRByteSizeFormatter
-(NSString*)stringForObjectValue:(id)obj
{
    float val = [obj floatValue];
    
    if(val < 1024)
        return [NSString stringWithFormat:@"%.0fB", val];
    
    val /= 1024.;
    if(val < 1024)
        return [NSString stringWithFormat:@"%.2fKB", val];

    val /= 1024.;
    if(val < 1024)
        return [NSString stringWithFormat:@"%.2fMB", val];
    
    val /= 1024.;
    if(val < 1024)
        return [NSString stringWithFormat:@"%.2fGB", val];
    
    val /= 1024.;
    return [NSString stringWithFormat:@"%.2fTB", val];
}
@end