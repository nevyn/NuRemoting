//
//  SPNuRemote.h
//  NuRemoting
//
//  Created by Joachim Bengtsson on 11/5/10.
//  Copyright 2010 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface SPNuRemote : NSObject {
	AsyncSocket *listenSocket;
}
-(void)run;
@end
