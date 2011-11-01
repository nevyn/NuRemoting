#import "LogViewer.h"

@interface LogLine : NSObject
{
	NSString *line;
	UIColor *color;
}
@property (retain, nonatomic) NSString *line;
@property (retain, nonatomic) UIColor *color;
@end
@implementation LogLine
@synthesize line, color;
-(void)dealloc;
{
	self.line = nil;
    self.color = nil;
	[super dealloc];
}
@end

@implementation LogView
-(id)initWithFrame:(CGRect)frame;
{
	if(![super initWithFrame:frame]) return nil;
	countMax = frame.size.height/12;
	lines = [[NSMutableArray alloc] initWithCapacity:countMax];
	font = [UIFont systemFontOfSize:9];
	return self;
}
-(void)dealloc;
{
	[lines release];
	[font release];
	[super dealloc];
}
-(void)drawRect:(CGRect)rect;
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
	CGContextFillRect(ctx, rect);
	
	[[UIColor brownColor] set];
	CGRect pen = CGRectMake(2, 0, 318, 16);
	for (LogLine *l in lines) {
		[l.color set];
		pen.size = [l.line sizeWithFont:font constrainedToSize:CGSizeMake(320, 1200)];
		[l.line drawInRect:pen withFont:font];
		pen.origin.y += pen.size.height + 1;
	}
	
	if(lines.count > countMax)
		[lines removeObjectsInRange:NSMakeRange(countMax, lines.count - countMax)];
}
-(void)writeLine:(NSString*)line withLevel:(NSUInteger)level;
{
	static UIColor *colors[14] = {nil};
	if(!colors[0]) {
		colors[0] = [[UIColor redColor] retain]; // fatal
		colors[1] = [[UIColor redColor] retain]; // assertion failure
		colors[2] = [[UIColor redColor] retain]; // error
		colors[3] = [[UIColor yellowColor] retain]; // warning
		colors[4] = [[UIColor blackColor] retain]; // info
		colors[5] = [[UIColor colorWithRed:0 green:0.5 blue:0.5 alpha:1] retain]; //spam
		colors[6] = [[UIColor colorWithRed:0 green:0.7 blue:0 alpha:1] retain]; // debug
		colors[7] = [[UIColor colorWithRed:0.5 green:0.5 blue:0 alpha:1] retain]; // debug1
		colors[8] = [[UIColor grayColor] retain]; // debug2
		colors[9] = [[UIColor cyanColor] retain]; // debug3
		colors[10] = [[UIColor colorWithRed:0.75 green:0.5 blue:0 alpha:.8] retain]; // debug4
		colors[11] = [[UIColor lightGrayColor] retain]; // debug5
		colors[12] = [[UIColor lightGrayColor] retain]; // debug6
		colors[13] = [[UIColor lightGrayColor] retain]; // debug7
	}

	LogLine *l = [[LogLine new] autorelease];
	l.line = line;
	l.color = colors[MIN(level, 13)];
	[lines insertObject:l atIndex:0];
	[self setNeedsDisplay];
}
@end



@implementation LogViewer
- (void)loadView {
	UIView *parent = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)] autorelease];
	parent.backgroundColor = [UIColor whiteColor];
		
	logView = [[LogView alloc] initWithFrame:CGRectMake(0, 0, 320, 2500)];
	logView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UIScrollView *scroll = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 450)] autorelease];
	scroll.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	scroll.contentSize = logView.frame.size;
	[scroll addSubview:logView];
	[parent addSubview:scroll];
	
	self.view = parent;
	self.title = @"Log";
}
- (void)viewDidUnload;
{
	[logView release]; logView = nil;
	[super viewDidUnload];
}
- (void)dealloc {
	[logView release]; logView = nil;
    [super dealloc];
}
-(void)writeLine:(NSString*)line withLevel:(NSUInteger)level;
{
	[logView writeLine:line withLevel:level];
}
@end
