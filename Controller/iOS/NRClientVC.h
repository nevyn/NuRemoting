#import <UIKit/UIKit.h>

@class RemotingClient;
@interface NRClientVC : UITabBarController
- (id)initWithClient:(RemotingClient*)client;
@end
