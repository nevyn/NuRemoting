#import "NRTextOnlyStatsCell.h"


@implementation NRTextOnlyStatsCell
@synthesize stats = _stats;
-(id)init;
{
    if(!(self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TextOnlyStatsCell"]))
        return nil;
    return self;
}
-(void)dealloc;
{
	_stats.delegate = nil;
    [_stats release];
    [super dealloc];
}
-(void)setStats:(NRStats *)stats;
{
	if(stats == _stats) return;
    if(_stats.delegate == self)
        _stats.delegate = nil;
	[_stats release];
	_stats = [stats retain];
	if(!_stats) return;
	_stats.delegate = self;
	
	self.textLabel.text = stats.name;
    self.detailTextLabel.text = [stats.formatter stringForObjectValue:stats.data.lastObject];
}
-(void)stats:(NRStats*)stats addedPoint:(float)pt at:(NSTimeInterval)when;
{
    self.detailTextLabel.text = [stats.formatter stringForObjectValue:stats.data.lastObject];
}
-(void)stats:(NRStats *)stats prunedPoints:(NSUInteger)deletedCount;
{}
-(void)didMoveToWindow;
{
    if(!self.window)
        self.stats = nil;
}
@end