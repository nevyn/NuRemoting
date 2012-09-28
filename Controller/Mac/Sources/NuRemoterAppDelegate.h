#import <Cocoa/Cocoa.h>

@interface NuRemoterAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
    NSWindow *window;
	NSNetServiceBrowser *browser;
	NSMutableArray *foundServices; // <NSNetService>
	IBOutlet NSTableView *tableView;
    NSTextField *customConnectField;
    NSTextField *customPortField;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *customConnectField;
@property (assign) IBOutlet NSTextField *customPortField;

-(IBAction)connect:(NSTableView*)sender;
-(IBAction)customConnect:(id)sender;
@end
