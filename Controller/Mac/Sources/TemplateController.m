#import "TemplateController.h"


@implementation TemplateController
+(NSString*)snippetFolder;
{
	NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *snippetFolder = [docs stringByAppendingPathComponent:@"NuRemoter Snippets"];
	return snippetFolder;
}
-(NSArray*)snippets;
{
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[self class] snippetFolder] error:nil];
	NSMutableArray *matchingFiles = [NSMutableArray array];
	for (NSString *file in files)
		if([file hasSuffix:@".nu"]) [matchingFiles addObject:file];
	return matchingFiles;
}
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox;
{
	return [self snippets].count;
}
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index;
{
	return [[self snippets] objectAtIndex:index];
}
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)string;
{
	return [[self snippets] indexOfObject:string];
}
-(void)comboBoxSelectionDidChange2;
{
	NSString *contents = [self contentsOfSnippetNamed:[comboBox stringValue]];
	if(contents)
		[destination.textStorage replaceCharactersInRange:NSMakeRange(0, destination.textStorage.string.length) withString:contents];

}
- (void)comboBoxSelectionDidChange:(NSNotification *)notification;
{
	[self performSelector:@selector(comboBoxSelectionDidChange2) withObject:nil afterDelay:0];
}
-(IBAction)save:(id)sender;
{
	[[NSFileManager defaultManager] createDirectoryAtPath:[[self class] snippetFolder] withIntermediateDirectories:YES attributes:nil error:nil];
	NSString *snippetPath = [[[self class] snippetFolder] stringByAppendingPathComponent:[comboBox stringValue]];
	NSError *err = nil;
	if(![destination.textStorage.string writeToFile:snippetPath atomically:YES encoding:NSUTF8StringEncoding error:&err])
		[NSApp presentError:err];
}
-(NSString*)contentsOfSnippetNamed:(NSString*)name;
{
	NSString *snippetPath = [[[self class] snippetFolder] stringByAppendingPathComponent:name];
	NSString *contents = [NSString stringWithContentsOfFile:snippetPath encoding:NSUTF8StringEncoding error:nil];
	return contents;
}

@end
