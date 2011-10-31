#import "NRStats.h"

@interface NRStats ()
@property(nonatomic,copy,readwrite) NSString *name;
@property(nonatomic,retain,readwrite) NSMutableArray *times, *data;
@end

@implementation NRStats
@synthesize name = _name, times = _times, data = _data, delegate = _delegate, maximumDataAge = _maximumDataAge, timeGranuality = _timeGranuality;
-(id)initWithName:(NSString*)name;
{
	if(!(self = [super init])) return nil;
	
	self.name = name;
	_times = [NSMutableArray new];
	_data = [NSMutableArray new];
	_maximumDataAge = 60;
	_timeGranuality = 0.05;
	
	return self;
}
-(void)dealloc;
{
	self.name = nil;
	self.times = nil;
	self.data = nil;
	[super dealloc];
}

-(void)addPoint:(float)point atTime:(NSTimeInterval)interval;
{
	NSTimeInterval latest = [[_times lastObject] doubleValue];
	if(interval - latest < _timeGranuality) return;
	
	[_times addObject:[NSNumber numberWithDouble:interval]];
	[_data addObject:[NSNumber numberWithFloat:point]];
	[_delegate stats:self addedPoint:point at:interval];
	
	NSTimeInterval oldestAllowed = interval - _maximumDataAge;
	int numDeletedPoints = 0;
	while([[_times objectAtIndex:0] doubleValue] < oldestAllowed) {
		[_times removeObjectAtIndex:0];
		[_data removeObjectAtIndex:0];
		numDeletedPoints++;
	}
	if(numDeletedPoints > 0)
		[_delegate stats:self prunedPoints:numDeletedPoints];
}
-(NSDictionary*)dictionaryRepresentation;
{
	NSMutableDictionary *d = [[[NSMutableDictionary alloc] initWithCapacity:_data.count] autorelease];
	for(int i = 0, c = _data.count; i < c; i++)
		[d setObject:[_data objectAtIndex:i] forKey:[_times objectAtIndex:i]];
	return d;
}
@end
