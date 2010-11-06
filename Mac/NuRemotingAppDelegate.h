//
//  NuRemotingAppDelegate.h
//  NuRemoting
//
//  Created by Joachim Bengtsson on 11/5/10.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NuRemotingAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
