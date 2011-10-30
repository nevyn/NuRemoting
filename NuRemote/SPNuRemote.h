//
//  SPNuRemote.h
//  NuRemoting
//
//  Created by Joachim Bengtsson on 11/5/10.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "Shared.h"

@class SPNuRemote;
@protocol SPNuRemoteDelegate <NSObject>
@optional
@end

@interface SPNuRemote : NSObject
@property (retain) AsyncSocket *listenSocket;
@property (retain) NSNetService *publisher;
@property (assign) id<SPNuRemoteDelegate> delegate;
-(void)run;

-(void)writeLogLine:(NSString*)line logLevel:(int)level;

-(void)addDataPoint:(float)data toDataSet:(NSString*)setName;
@end
