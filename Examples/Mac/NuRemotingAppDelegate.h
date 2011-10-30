//
//  NuRemotingAppDelegate.h
//  NuRemoting
//
//  Created by Joachim Bengtsson on 11/5/10.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SPNuRemote;
@interface NuRemotingAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	SPNuRemote *remote;
}

@property (assign) IBOutlet NSWindow *window;

@end
