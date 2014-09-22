#import <Cocoa/Cocoa.h>

@interface NuRemoterAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>
@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *customConnectField;
@property (weak) IBOutlet NSTextField *customPortField;

-(IBAction)connect:(NSTableView*)sender;
-(IBAction)customConnect:(id)sender;
@end
