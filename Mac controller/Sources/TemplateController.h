#import <Cocoa/Cocoa.h>


@interface TemplateController : NSObject <NSComboBoxDataSource, NSComboBoxDelegate> {
	IBOutlet NSTextView *destination;
	IBOutlet NSComboBox *comboBox;
}

-(IBAction)save:(id)sender;
-(NSString*)contentsOfSnippetNamed:(NSString*)name;
@end
