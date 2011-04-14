//
//  SPNuRemote.m
//  NuRemoting
//
//  Created by Joachim Bengtsson on 11/5/10.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import "SPNuRemote.h"
#import "SPIOSLog.h"

// forward
@interface SpotifyAppDelegate : NSObject
+(SpotifyAppDelegate*)appDelegate;
-(SPIOSLog*)log;
@end

//#import <Nu/Nu.h>
@interface NSObject (NuStuff)
+(id)parser;
-(void)reset;
-(id)parseEval:(NSString*)code;
@end

static const int kNuRemotingPort = 8023;
static NSString *kNuRemotingBonjourType = @"_nuremote._tcp.";


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
-(void)enableRemoteLogging;
{
	[[SpotifyAppDelegate appDelegate].log.delegates addObject:self];
}
-(void)disableRemoteLogging;
{
	[[SpotifyAppDelegate appDelegate].log.delegates removeObject:self];
}

-(id)init:(AsyncSocket*)s;
{
	parser = [[NSClassFromString(@"Nu") parser] retain];
	if(!parser)
		return nil;
	
	sock = [s retain];
	[parser parseEval:@"(set log (NuBridgedFunction functionWithName:\"NSLog\" signature:\"v@\"))"];
	[parser setValue:self forKey:@"remote"];
	[self enableRemoteLogging];
	
	[sock setDelegate:self];
	[sock readDataToData:[SPNRClient doubleNewline] withTimeout:-1 tag:0];
	return self;
}
-(void)dealloc;
{
	[self disableRemoteLogging];
	[sock release];
	[parser release];
	[super dealloc];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock_;
{
	[parser setValue:nil forKey:@"remote"];
	[sock release]; sock = nil;
	[self release];
}
-(void)reply:(NSString*)code :(NSString*)reply;
{
	NSData *d = [[NSString stringWithFormat:@"%@\t%@\n\n", code, reply] dataUsingEncoding:NSUTF8StringEncoding];
	[sock writeData:d withTimeout:-1 tag:0];
	[sock readDataToData:[SPNRClient doubleNewline] withTimeout:-1 tag:0];
}

-(void)replyData:(NSData*)data
{
	NSData *header = [[NSString stringWithFormat:@"201 OK data transfer\t\nContent-Length: %d\n\n", [data length]] dataUsingEncoding:NSUTF8StringEncoding];
	[sock writeData:header withTimeout:-1 tag:0];
	[sock writeData:data withTimeout:-1 tag:0];
	[sock readDataToData:[SPNRClient doubleNewline] withTimeout:-1 tag:0];
}


- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
	NSString *cmd = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	if(!cmd) return [self reply:@"501 Bad Request" :@"Command not UTF8"];
	
	NSString *reply = nil;
	@try {
		reply = [parser parseEval:cmd];
	}
	@catch (NSException * e) {
		[self reply:@"502 Exception Thrown" :[e description]];
		[parser reset];
		return;
	}
	
	return [self reply:@"200 OK" :reply];
}
-(void)log:(SPIOSLog*)log wroteLine:(NSString*)line withFlags:(uint)flags;
{
	int logLevel = flags % 0xf;
	[self reply:[NSString stringWithFormat:@"6%02d Log message", logLevel] :[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}
@end



@implementation SPNuRemote
@synthesize listenSocket, publisher;
-(void)run;
{
	if(!NSClassFromString(@"Nu") || listenSocket)
		return;

	self.listenSocket = [[[AsyncSocket alloc] initWithDelegate:self] autorelease];
	self.publisher = [[[NSNetService alloc] initWithDomain:@"" type:kNuRemotingBonjourType name:[UIDevice currentDevice].name	port:kNuRemotingPort] autorelease];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activated) name:UIApplicationDidBecomeActiveNotification object:nil];
	
	NSError *err = nil;
	if(![listenSocket acceptOnPort:kNuRemotingPort error:&err]) {
		NSLog(@"SPNuRemote listen failure: %@", err);
		return;
	}
		

	[publisher publish];
}
-(void)dealloc;
{
	self.listenSocket = nil;
	self.publisher = nil;
	[super dealloc];
}
-(void)activated;
{
	[self.publisher stop];
	listenSocket.delegate = nil;
	[listenSocket disconnect];
	listenSocket.delegate = self;
	NSError *err = nil;
	if(![listenSocket acceptOnPort:kNuRemotingPort error:&err])
		NSLog(@"SPNuRemote listen failure: %@", err);
	else
		[self.publisher publish];
}


- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
{
	[[SPNRClient alloc] init:newSocket];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	self.listenSocket = self.publisher = (id)nil;
	[self activated];
}
@end
