//
//  RongCloudPlugin.h
//  Smobiler
//
//  Created by sun on 2016/10/27.
//
//

#ifndef RongCloudPlugin_h
#define RongCloudPlugin_h

#import <Foundation/Foundation.h>

@interface RongCloudPlugin : NSObject

- (void) start:(NSDictionary*) dict callid:(NSString *)callid callback:(void (^)(NSString *, NSString*)) cb;

+ (void) checkConnect;
+ (void) jumpToRYController:(NSDictionary *) dict;

@end

#endif /* RongCloudPlugin_h */
