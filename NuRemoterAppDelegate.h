#import <Cocoa/Cocoa.h>

@interface NuRemoterAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
    NSWindow *window;
	NSNetServiceBrowser *browser;
	NSMutableArray *foundServices; // <NSNetService>
	IBOutlet NSTableView *tableView;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)connect:(NSTableView*)sender;

@end
