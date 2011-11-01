#import <UIKit/UIKit.h>
@class LogView;
@interface LogViewer : UIViewController
{
	LogView *logView;
}
-(void)writeLine:(NSString*)line withLevel:(NSUInteger)level;
@end

@interface LogView : UIView
{
	NSMutableArray *lines;
	int countMax;
	UIFont *font;
}
-(void)writeLine:(NSString*)line withLevel:(NSUInteger)level;
@end