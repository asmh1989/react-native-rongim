//
//  RCDRCIMDelegateImplementation.m
//  RongCloud
//
//  Created by Liv on 14/11/11.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>
#import "RCDRCIMDataSource.h"

@interface RCDRCIMDataSource ()
{
    NSString *url_header;
}

@end

@implementation RCDRCIMDataSource

+ (RCDRCIMDataSource *)shareInstance {
    static RCDRCIMDataSource *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)syncGroups {
    //开发者调用自己的服务器接口获取所属群组信息
    
}

- (void)syncFriendList:(NSString *)userId
              complete:(void (^)(NSMutableArray *friends))completion {
}

#pragma mark - GroupInfoFetcherDelegate
- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *))completion {
    if ([groupId length] == 0)
        return;
    
    url_header=[NSString stringWithFormat:@"http://%s:%d", Configs::getInstance()->getServer().c_str(), Configs::getInstance()->getImagePort()];

    NSString* url = [url_header stringByAppendingFormat:@"/im/rong/groupinfo?token=%@", groupId];
    
    NSDictionary* dict = [self getDataFromUrl:url];
    

    RCGroup *group = [RCGroup new];
    
    if(dict)
    {
        group.groupId = [dict valueForKey:@"GroupID"];
        group.portraitUri = [dict valueForKey:@"PortraitUri"];
        group.groupName = [dict valueForKey:@"GroupName"];
        
        if (![group.portraitUri hasPrefix:@"http"])
        {
            group.portraitUri = [url_header stringByAppendingString:group.portraitUri];
        }
    }
    
    completion(group);
    
}

-(NSDictionary *) getDataFromUrl:(NSString *)surl
{
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:surl];
    
    //第二步，通过URL创建网络请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSString *deviceId = [NSString stringWithFormat:@"%s",CADeviceId::newInstance()->getDeviceId().c_str()];
    [request setValue:deviceId forHTTPHeaderField:@"X-CLIENT-ID"];
    //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
    //第三步，连接服务器
    NSData *jsondata = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSError* error;
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsondata options:kNilOptions error:&error];
    
    if(error){
        return nil;
    } else {
        return dict;
    }
}

-(NSArray *) getMenberFromUrl:(NSString *)surl
{
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:surl];
    
    //第二步，通过URL创建网络请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSString *deviceId = [NSString stringWithFormat:@"%s",CADeviceId::newInstance()->getDeviceId().c_str()];
    [request setValue:deviceId forHTTPHeaderField:@"X-CLIENT-ID"];
    //NSURLRequest初始化方法第一个参数：请求访问路径，第二个参数：缓存协议，第三个参数：网络请求超时时间（秒）
    //第三步，连接服务器
    NSData *jsondata = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSError* error;
    
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsondata options:kNilOptions error:&error];
    
    if(error){
        return nil;
    } else {
        return array;
    }
}

#pragma mark - RCIMUserInfoDataSource
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *))completion {
    NSLog(@"getUserInfoWithUserId ----- %@", userId);
    RCUserInfo *user = [RCUserInfo new];
    user.userId = userId;
    user.portraitUri = @"";
    user.name = @"";
    
    if(userId.length == 0) {
        return;
    }
    
    url_header=[NSString stringWithFormat:@"http://%s:%d", Configs::getInstance()->getServer().c_str(), Configs::getInstance()->getImagePort()];
    
    NSString* url = [url_header stringByAppendingFormat:@"/im/rong/userinfo?token=%@", userId];
    
    NSDictionary* dict = [self getDataFromUrl:url];
    
    if(dict){
        user.userId = [dict valueForKey:@"UserID"];
        user.portraitUri = [dict valueForKey:@"PortraitUri"];
        user.name = [dict valueForKey:@"UserName"];
        
        if (![user.portraitUri hasPrefix:@"http"])
        {
            user.portraitUri = [url_header stringByAppendingString:user.portraitUri];
        }
    }
    
    completion(user);

    return;
}

#pragma mark - RCIMGroupUserInfoDataSource
/**
 *  获取群组内的用户信息。
 *  如果群组内没有设置用户信息，请注意：1，不要调用别的接口返回全局用户信息，直接回调给我们nil就行，SDK会自己巧用用户信息提供者；2一定要调用completion(nil)，这样SDK才能继续往下操作。
 *
 *  @param groupId  群组ID.
 *  @param completion 获取完成调用的BLOCK.
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                      inGroup:(NSString *)groupId
                   completion:(void (^)(RCUserInfo *userInfo))completion {
    //在这里查询该group内的群名片信息，如果能查到，调用completion返回。如果查询不到也一定要调用completion(nil)
    if ([groupId isEqualToString:@"22"] && [userId isEqualToString:@"30806"]) {
        completion([[RCUserInfo alloc] initWithUserId:@"30806"
                                                 name:@"我在22群中的名片"
                                             portrait:nil]);
    } else {
        completion(
                   nil); //融云demo中暂时没有实现，以后会添加上该功能。app也可以自己实现该功能。
    }
}

- (void)getAllMembersOfGroup:(NSString *)groupId
                      result:(void (^)(NSArray<NSString *> *))resultBlock {
    NSLog(@"getAllMembersOfGroup ----- %@", groupId);
    
    if(groupId.length == 0) {
        return;
    }
    
    url_header=[NSString stringWithFormat:@"http://%s:%d", Configs::getInstance()->getServer().c_str(), Configs::getInstance()->getImagePort()];
    
    NSString* url = [url_header stringByAppendingFormat:@"/im/rong/groupmembers?token=%@", groupId];
    
    NSArray* userIdList = [self getMenberFromUrl:url];
    
    resultBlock(userIdList);
    
    return;
}

//- (NSArray *)getAllUserInfo:(void (^)())completion {
//  return [[RCDataBaseManager shareInstance] getAllUserInfo];
//}
//
//- (NSArray *)getAllGroupInfo:(void (^)())completion {
//  return [[RCDataBaseManager shareInstance] getAllGroup];
//}
//
//- (NSArray *)getAllFriends:(void (^)())completion {
//  return [[RCDataBaseManager shareInstance] getAllFriends];
//}
@end
