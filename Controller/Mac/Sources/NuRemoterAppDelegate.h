#import <Cocoa/Cocoa.h>

@interface NuRemoterAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
    NSWindow *__weak window;
	NSNetServiceBrowser *browser;
	NSMutableArray *foundServices; // <NSNetService>
	IBOutlet NSTableView *tableView;
    NSTextField *__weak customConnectField;
    NSTextField *__weak customPortField;
}

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *customConnectField;
@property (weak) IBOutlet NSTextField *customPortField;

-(IBAction)connect:(NSTableView*)sender;
-(IBAction)customConnect:(id)sender;
@end
