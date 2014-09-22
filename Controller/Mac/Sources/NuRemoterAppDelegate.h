#import <Cocoa/Cocoa.h>

@interface NuRemoterAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>

-(IBAction)connect:(NSTableView*)sender;
-(IBAction)customConnect:(id)sender;
@end
