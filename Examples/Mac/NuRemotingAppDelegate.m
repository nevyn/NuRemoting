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
	[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(hej) userInfo:nil repeats:YES];
	[NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(stats) userInfo:nil repeats:YES];
}
-(void)hej;
{
	[remote writeLogLine:@"Hej!" logLevel:4];
}
-(void)stats;
{
	double loadavg[1];
	getloadavg(loadavg, 1);
	[remote addDataPoint:loadavg[0] toDataSet:@"cpuload"];
}

@end
