#import <Cocoa/Cocoa.h>


@interface TemplateController : NSObject <NSComboBoxDataSource, NSComboBoxDelegate>
-(NSString*)contentsOfSnippetNamed:(NSString*)name;
@end
