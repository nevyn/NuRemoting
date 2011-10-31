#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "Shared.h"

@interface SPNuRemote : NSObject
@property (retain) AsyncSocket *listenSocket;
@property (retain) NSNetService *publisher;
-(void)run;

-(void)writeLogLine:(NSString*)line logLevel:(int)level;

-(void)addDataPoint:(float)data toDataSet:(NSString*)setName;
@end
