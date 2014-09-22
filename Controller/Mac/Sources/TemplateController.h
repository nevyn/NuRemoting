#import <Cocoa/Cocoa.h>


@interface TemplateController : NSObject <NSComboBoxDataSource, NSComboBoxDelegate>
-(IBAction)save:(id)sender;
-(NSString*)contentsOfSnippetNamed:(NSString*)name;
@end
