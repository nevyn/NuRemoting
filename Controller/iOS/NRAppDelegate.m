#import "NRAppDelegate.h"
#import "NRHostFinder.h"

@implementation NRAppDelegate {
	UINavigationController *root;
	NRHostFinder *top;
}
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
	
	top = [NRHostFinder new];
	root = [[UINavigationController alloc] initWithRootViewController:top];
	self.window.rootViewController = root;
	
    return YES;
}
- (void)dealloc
{
	[top release];
	[root release];
	[_window release];
    [super dealloc];
}

@end
