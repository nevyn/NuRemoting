#import "NRStatsViewer.h"
#import	"RemotingClient.h"
#import "NRStats.h"
#import "NRStatsCell.h"

@implementation NRStatsViewer {
	RemotingClient *_client;
	NSMutableArray *statSets;
}
-(id)initWithClient:(RemotingClient*)client;
{
	if(!(self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])) return nil;
	
	statSets = [NSMutableArray new];
	
	_client = client;
	
	self.title = @"Stats";
	
	return self;
}
-(void)dealloc;
{
	_client = nil;
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
