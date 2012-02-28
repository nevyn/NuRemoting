#import "NRStatsViewer.h"
#import "NRStats.h"
#import "NRStatsCell.h"

@implementation NRStatsViewer {
	NSMutableArray *statSets;
}
-(id)init;
{
	if(!(self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])) return nil;
	
	statSets = [NSMutableArray new];
	
	self.title = @"Stats";
	
	return self;
}
-(void)dealloc;
{
	[statSets release];
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
    static NSString *CellIdentifier = @"StatsCell";
    
    NRStatsCell *cell = (id)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[NRStatsCell new] autorelease];
    
	cell.stats = [statSets objectAtIndex:indexPath.row];
    
    return cell;
}


@end
