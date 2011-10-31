#import <Foundation/Foundation.h>

@class NRStats;
@protocol NRStatsDelegate <NSObject>
-(void)stats:(NRStats*)stats addedPoint:(float)pt at:(NSTimeInterval)when;
-(void)stats:(NRStats *)stats prunedPoints:(NSUInteger)deletedCount;
@end

@interface NRStats : NSObject {
	NSString *_name;
	NSMutableArray *_times;
	NSMutableArray *_data;
	id<NRStatsDelegate> _delegate;
	NSTimeInterval _maximumDataAge;
}
@property(nonatomic,copy,readonly) NSString *name;
@property(nonatomic,retain,readonly) NSMutableArray *times, *data;
@property(nonatomic) NSTimeInterval maximumDataAge; // default 60
@property(nonatomic,assign) id<NRStatsDelegate> delegate;

-(id)initWithName:(NSString*)name;
-(void)addPoint:(float)point atTime:(NSTimeInterval)interval;
-(NSDictionary*)dictionaryRepresentation;
@end
