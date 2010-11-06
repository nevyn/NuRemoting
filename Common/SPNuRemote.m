//
//  SPNuRemote.m
//  NuRemoting
//
//  Created by Joachim Bengtsson on 11/5/10.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import "SPNuRemote.h"
#import <Nu/Nu.h>

@interface SPNRClient : NSObject
{
	AsyncSocket *sock;
	id parser;
}
-(id)init:(AsyncSocket*)s;
@end
@implementation SPNRClient
+(NSData*)doubleNewline;
{
	static NSData *dnl = nil;
	if(!dnl) dnl = [[NSData dataWithBytes:"\xa\xa" length:2] retain];
	return dnl;
}
-(id)init:(AsyncSocket*)s;
{
	sock = [s retain];
	parser = [[Nu parser] retain];
	[parser parseEval:@"(set log (NuBridgedFunction functionWithName:\"NSLog\" signature:\"v@\"))"];

	[sock setDelegate:self];
	[sock readDataToData:[SPNRClient doubleNewline] withTimeout:-1 tag:0];
	return self;
}
-(void)dealloc;
{
	[sock release];
	[parser release];
	[super dealloc];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	[self release];
}
-(void)reply:(NSString*)code :(NSString*)reply;
{
	NSData *d = [[NSString stringWithFormat:@"%@\t%@\n\n", code, reply] dataUsingEncoding:NSUTF8StringEncoding];
	[sock writeData:d withTimeout:-1 tag:0];
	[sock readDataToData:[SPNRClient doubleNewline] withTimeout:-1 tag:0];
}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
	NSString *cmd = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if(!cmd) return [self reply:@"400 Bad Request" :@"Command not UTF8"];
	
	NSString *reply = nil;
	@try {
		reply = [parser parseEval:cmd];
	}
	@catch (NSException * e) {
		return [self reply:@"500 Exception Thrown" :[e description]];
	}
	
	return [self reply:@"200 OK" :reply];
}
@end



@implementation SPNuRemote
-(void)run;
{
	listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
	[listenSocket acceptOnPort:8023 error:nil];
}
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	[[SPNRClient alloc] init:newSocket];
}
@end
