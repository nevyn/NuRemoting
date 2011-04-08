//
//  RemotingClient.m
//  NuRemoter
//
//  Created by Joachim Bengtsson on 2011-03-22.
//  Copyright 2011 Spotify AB. All rights reserved.
//

#import "RemotingClient.h"

NSString *kNuRemotingBonjourType = @"_nuremote._tcp.";

@interface RemotingClient ()
@property (readwrite, retain) AsyncSocket *socket;
@end



@implementation RemotingClient
+(NSData*)messageSeparator;
{
	static NSData *dnl = nil;
	if(!dnl) dnl = [[NSData dataWithBytes:"\xa\xa" length:2] retain];
	return dnl;
}

@synthesize delegate, socket, name;
+(void)performSearchOnBrowser:(NSNetServiceBrowser*)browser;
{
	[browser searchForServicesOfType:kNuRemotingBonjourType inDomain:@""];
}
-(id)initWithService:(NSNetService*)service error:(NSError**)err;
{
	self.socket = [[[AsyncSocket alloc] initWithDelegate:self] autorelease];
	[self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];

	if(![socket connectToAddress:[service.addresses objectAtIndex:0] error:err]) {
		[self release];
		return nil;
	}
	
	self.name = service.name;
	
	return self;
}
-(id)initWithHost:(NSString*)host port:(int)port error:(NSError**)err;
{
	self.socket = [[[AsyncSocket alloc] initWithDelegate:self] autorelease];
	[self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];

	if(![socket connectToHost:host onPort:port error:err]) {
		[self release];
		return nil;
	}
	
	self.name = host;
	
	return self;

}
-(void)dealloc;
{
	self.socket.delegate = nil;
	self.socket = nil;
	[super dealloc];
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err;
{
	[delegate remotingClient:self willDisconnectWithError:err];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[delegate remotingClientDisconnected:self];
	self.socket = nil;
}
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	[socket readDataToData:[RemotingClient messageSeparator] withTimeout:-1 tag:0];
	[delegate remotingClientConnected:self];
}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSString *cmd = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSString *code = [cmd substringToIndex:[cmd rangeOfString:@" "].location];
	NSRange r;
	r.location = [cmd rangeOfString:@"\t"].location + 1;
	r.length = [cmd length]-r.location - [RemotingClient messageSeparator].length;
	NSString *output = [cmd substringWithRange:r];
	[delegate remotingClient:self receivedOutput:output withStatusCode:[code intValue]];
	
	[socket readDataToData:[RemotingClient messageSeparator] withTimeout:-1 tag:0];
}
-(void)sendCommand:(NSString*)commands;
{
	NSMutableData *data = [NSMutableData data];
	[data appendData:[commands dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[RemotingClient messageSeparator]];
	[socket writeData:data withTimeout:-1 tag:0];
}


@end
