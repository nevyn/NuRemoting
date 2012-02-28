#import "NRStatsViewer.h"
#import "NRStats.h"
#import "NRStatsCell.h"
#import "NRTextOnlyStatsCell.h"

@implementation NRStatsViewer {
	NSMutableArray *statSets;
    NSMutableSet *expandedSetNames;
}
-(id)init;
{
	if(!(self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])) return nil;
	
	statSets = [NSMutableArray new];
    expandedSetNames = [NSMutableSet new];
	
	self.title = @"Stats";
	
	return self;
}
-(void)dealloc;
{
	[statSets release];
    [expandedSetNames release];
	[super dealloc];
}

-(NRStats*)statsNamed:(NSString*)name;
{
	for(NRStats *stats in statSets)
		if([stats.name isEqual:name]) return stats;
	NRStats *stats = [[[NRStats alloc] initWithName:name] autorelease];
	[[self mutableArrayValueForKey:@"statSets"] addObject:stats];
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
	return stats;
}


-(void)addPoint:(float)pt at:(NSTimeInterval)sinceRef inSet:(NSString*)datasetName;
{
	[[self statsNamed:datasetName] addPoint:pt atTime:sinceRef];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	return statSets.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NRStats *stats = [statSets objectAtIndex:indexPath.row];
    BOOL expanded = [expandedSetNames containsObject:stats.name];
    
    NSString *CellIdentifier = expanded?@"StatsCell":@"TextOnlyStatsCell";
    
    id cell = (id)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [expanded?[NRStatsCell new]:[NRTextOnlyStatsCell new] autorelease];
    
	[cell setStats:stats];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NRStats *stats = [statSets objectAtIndex:indexPath.row];
    if([expandedSetNames containsObject:stats.name])
        [expandedSetNames removeObject:stats.name];
    else
        [expandedSetNames addObject:stats.name];
    
    [self.tableView reloadData];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NRStats *stats = [statSets objectAtIndex:indexPath.row];
    return [expandedSetNames containsObject:stats.name] ? 100 : 44;
}
@end
