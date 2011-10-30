//
//  NuRemotingAppDelegate.m
//  NuRemoting
//
//  Created by Joachim Bengtsson on 11/5/10.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import "NuRemotingAppDelegate.h"
#import "SPNuRemote.h"

@implementation NuRemotingAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	remote = [SPNuRemote new];
	[remote run];
}

@end
