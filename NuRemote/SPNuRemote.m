//
//  SPNuRemote.m
//  NuRemoting
//
//  Created by Joachim Bengtsson on 11/5/10.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import "SPNuRemote.h"

#if !TARGET_OS_IPHONE
#import <SystemConfiguration/SystemConfiguration.h>
#endif

//#import <Nu/Nu.h>
@interface NSObject (NuStuff)
+(id)parser;
-(void)reset;
-(id)parseEval:(NSString*)code;
@end


@interface SPNuRemote ()
@property(nonatomic,readonly) NSMutableArray *clients;
@property(nonatomic,readonly) NSMutableDictionary *datasets;
@end


@interface SPNRClient : NSObject
{
	AsyncSocket *sock;
	id parser;
	SPNuRemote *parent;
}
-(id)init:(AsyncSocket*)s :(SPNuRemote*)parent_;
-(void)sendInitialDatasets;
@end
@implementation SPNRClient
+(NSData*)doubleNewline;
{
	static NSData *dnl = nil;
	if(!dnl) dnl = [[NSData dataWithBytes:"\xa\xa" length:2] retain];
	return dnl;
}

-(id)init:(AsyncSocket*)s :(SPNuRemote*)parent_;
{
	parser = [[NSClassFromString(@"Nu") parser] retain];
	if(!parser)
		return nil;
	
	parent = parent_;
	sock = [s retain];
	[parser parseEval:@"(set log (NuBridgedFunction functionWithName:\"NSLog\" signature:\"v@\"))"];
	
	[sock setDelegate:self];
	[sock readDataToData:[SPNRClient doubleNewline] withTimeout:-1 tag:0];
	
	[self sendInitialDatasets];
	return self;
}
-(void)dealloc;
{
	[sock release];
	[parser release];
	[super dealloc];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock_;
{
	[sock release]; sock = nil;
	[parent.clients removeObject:self]; // I will be deallocated now
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
-(void)writeLogLine:(NSString*)line logLevel:(int)logLevel;
{
	[self reply:[NSString stringWithFormat:@"6%02d Log message", logLevel] :[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}
-(void)addDataPoint:(float)data atTime:(NSTimeInterval)interval toDataSet:(NSString*)setName;
{
	[self reply:@"701 New Data Point" :[NSString stringWithFormat:@"%@\n%f\n%f", 
		setName, interval, data
	]];
}
-(void)sendInitialDatasets;
{
	for(NSString *setName in parent.datasets.allKeys) {
		NSMutableDictionary *dataset = [parent.datasets objectForKey:setName];
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataset];
		NSData *header = [[NSString stringWithFormat:@"702 Dataset Priming\t\nSet-Name: %@\nContent-Length: %d\n\n", setName, [data length]] dataUsingEncoding:NSUTF8StringEncoding];
		[sock writeData:header withTimeout:-1 tag:0];
		[sock writeData:data withTimeout:-1 tag:0];
	}

}
@end



@implementation SPNuRemote
@synthesize listenSocket, publisher, delegate, clients, datasets;
-(id)init;
{
	clients = [NSMutableArray new];
	datasets = [NSMutableDictionary new];

	return self;
}
-(void)run;
{
	if(!NSClassFromString(@"Nu") || listenSocket)
		return;

	self.listenSocket = [[[AsyncSocket alloc] initWithDelegate:self] autorelease];
	
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	
#if TARGET_OS_IPHONE
	NSString *deviceName = [UIDevice currentDevice].name;
#else
	SCDynamicStoreRef dynstore = SCDynamicStoreCreate(kCFAllocatorSystemDefault, (CFStringRef)appName, nil, nil);
	NSDictionary *computerNameEntry = [(id)SCDynamicStoreCopyValue(dynstore,(CFStringRef)@"Setup:/System") autorelease];
	CFRelease(dynstore);
	NSString *deviceName = [computerNameEntry objectForKey:@"ComputerName"];
#endif
	NSString *pubName = [NSString stringWithFormat:@"%@: %@",
		deviceName,
		appName
	];
	
	self.publisher = [[[NSNetService alloc] initWithDomain:@"" type:kNuRemotingBonjourType name:pubName	port:kNuRemotingPort] autorelease];
	
#if TARGET_OS_IPHONE
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activated) name:UIApplicationDidBecomeActiveNotification object:nil];
#endif
	
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
	[clients release];
	[datasets release];
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
	[clients addObject:[[[SPNRClient alloc] init:newSocket :self] autorelease]];
}
- (void)onSocketDidDisconnect:(AsyncSocket *)sock;
{
	self.listenSocket = nil;
	self.publisher = nil;
	[self activated];
}

-(void)writeLogLine:(NSString *)line logLevel:(int)level;
{
	for(SPNRClient *client in clients)
		[client writeLogLine:line logLevel:level];
}

-(void)addDataPoint:(float)data toDataSet:(NSString*)setName;
{
	NSMutableDictionary *dataset = [datasets objectForKey:setName];
	if(!dataset) {
		dataset = [NSMutableDictionary dictionaryWithCapacity:1000];
		[datasets setObject:dataset forKey:setName];
	}
	
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	
	[dataset setObject:[NSNumber numberWithFloat:data] forKey:[NSNumber numberWithDouble:now]];
	for(SPNRClient *client in clients)
		[client addDataPoint:data atTime:now toDataSet:setName];
}
@end
