//
//  TemplateController.h
//  NuRemoter
//
//  Created by Joachim Bengtsson on 2011-04-08.
//  Copyright 2011 Spotify AB. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TemplateController : NSObject <NSComboBoxDataSource, NSComboBoxDelegate> {
	IBOutlet NSTextView *destination;
	IBOutlet NSComboBox *comboBox;
}

-(IBAction)save:(id)sender;
-(NSString*)contentsOfSnippetNamed:(NSString*)name;
@end
