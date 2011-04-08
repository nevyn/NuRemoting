//
//  RemotingClient.h
//  NuRemoter
//
//  Created by Joachim Bengtsson on 2011-03-22.
//  Copyright 2011 Spotify AB. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"

extern NSString *kNuRemotingBonjourType;

enum RemotingStatusCodes {
	RemotingStatusOK = 200,
	RemotingStatusBadRequest = 400,
	RemotingStatusException = 500
};


@class RemotingClient;
@protocol RemotingClientDelegate <NSObject>
-(void)remotingClient:(RemotingClient*)client receivedOutput:(NSString*)output withStatusCode:(int)code;
-(void)remotingClientConnected:(RemotingClient*)client;
-(void)remotingClient:(RemotingClient*)client willDisconnectWithError:(NSError*)err;
-(void)remotingClientDisconnected:(RemotingClient*)client;
@end


@interface RemotingClient : NSObject {
	id<RemotingClientDelegate> delegate;
	AsyncSocket *socket;
	NSString *name;
}
@property (assign) id<RemotingClientDelegate> delegate;
@property (copy) NSString *name;
@property (readonly, retain) AsyncSocket *socket;
+(void)performSearchOnBrowser:(NSNetServiceBrowser*)browser;
-(id)initWithService:(NSNetService*)service error:(NSError**)err;
-(id)initWithHost:(NSString*)host port:(int)port error:(NSError**)err;

-(void)sendCommand:(NSString*)commands;
@end
