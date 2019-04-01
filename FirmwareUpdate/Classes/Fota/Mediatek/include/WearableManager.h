#import <Foundation/Foundation.h>

@interface WearableManager : NSObject

+ (id)wearableMgrInstance;

- (BOOL)isConnectedState;
- (BOOL)isAvaiable;

@end
