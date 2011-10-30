//
//  RemotingClient.m
//  NuRemoter
//
//  Created by Joachim Bengtsson on 2011-03-22.
//  Copyright 2011 Spotify AB. All rights reserved.
//

#import "RemotingClient.h"

@interface RemotingClient ()
@property (readwrite, retain) AsyncSocket *socket;
@end

typedef enum {
	kReadingCommand = 0,
	kReadingData = 1,
	kReadingDatasetPriming = 2,
} ReadingType;

NSDictionary *SPKeyValueStringToDict(NSString *kvString);
NSDictionary *SPKeyValueStringToDict(NSString *kvString) {
	NSArray *lines = [kvString componentsSeparatedByString:@"\n"];
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[lines count]];
	for (NSString *line in lines) {
		NSArray *keyAndValue = [line componentsSeparatedByString:@":"];
		if([keyAndValue count] != 2) continue;
		NSString *key = [[keyAndValue objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSString *value = [[keyAndValue objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[dict setObject:value forKey:key];
	}
	return dict;
}

@interface RemotingClient ()
@property(nonatomic,copy) NSString *incomingDatasetName;
@end


@implementation RemotingClient
+(NSData*)messageSeparator;
{
	static NSData *dnl = nil;
	if(!dnl) dnl = [[NSData dataWithBytes:"\xa\xa" length:2] retain];
	return dnl;
}

@synthesize delegate, socket, name, incomingDatasetName;
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
	[socket readDataToData:[RemotingClient messageSeparator] withTimeout:-1 tag:kReadingCommand];
	[delegate remotingClientConnected:self];
}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	if(tag == kReadingCommand) {
		NSString *cmd = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
		NSString *code = [cmd substringToIndex:[cmd rangeOfString:@" "].location];
		NSRange r;
		r.location = [cmd rangeOfString:@"\t"].location + 1;
		r.length = [cmd length]-r.location - [RemotingClient messageSeparator].length;
		NSString *output = [cmd substringWithRange:r];
		
		if(SPRemoteHasDataAttachment([code intValue])) {
			NSDictionary *settings = SPKeyValueStringToDict(output);
			int length = [[settings objectForKey:@"Content-Length"] intValue];
			
			if([code intValue] == RemotingStatusStatsPriming) {
				self.incomingDatasetName = [settings objectForKey:@"Set-Name"];
				[delegate remotingClient:self receivedOutput:[NSString stringWithFormat:@"Receiving %d bytes of stats...", length] withStatusCode:[code intValue]];
				
				[socket readDataToLength:length withTimeout:-1 tag:kReadingDatasetPriming];
			} else if([code intValue] == RemotingDataReply) {
				[delegate remotingClient:self receivedOutput:[NSString stringWithFormat:@"Receiving %d bytes of data...", length] withStatusCode:[code intValue]];
				[socket readDataToLength:length withTimeout:-1 tag:kReadingData];
			}
		} else {
			[delegate remotingClient:self receivedOutput:output withStatusCode:[code intValue]];
			[socket readDataToData:[RemotingClient messageSeparator] withTimeout:-1 tag:kReadingCommand];
		}
		
	} else if (tag == kReadingData) {
		[delegate remotingClient:self receivedOutput:[NSString stringWithFormat:@"Received %d bytes of data.", [data length]] withStatusCode:201];
		[delegate remotingClient:self receivedData:data];
		[socket readDataToData:[RemotingClient messageSeparator] withTimeout:-1 tag:kReadingCommand];
	} else if (tag == kReadingDatasetPriming) {
		NSDictionary *primedStats = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		[delegate remotingClient:self receivedOutput:[NSString stringWithFormat:@"Primed %@ with %d data points.", self.incomingDatasetName, [primedStats count]] withStatusCode:201];
		
		for(NSNumber *when in primedStats)
			[delegate remotingClient:self receivedPoint:[[primedStats objectForKey:when] floatValue] at:[when floatValue] inSet:self.incomingDatasetName];
		
		self.incomingDatasetName = nil;

		[socket readDataToData:[RemotingClient messageSeparator] withTimeout:-1 tag:kReadingCommand];
	}
}
-(void)sendCommand:(NSString*)commands;
{
	NSMutableData *data = [NSMutableData data];
	[data appendData:[commands dataUsingEncoding:NSUTF8StringEncoding]];
	[data appendData:[RemotingClient messageSeparator]];
	[socket writeData:data withTimeout:-1 tag:0];
}


@end
