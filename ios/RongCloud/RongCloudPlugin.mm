//
//  RongCloudPlugin.m
//  Smobiler
//
//  Created by sun on 2016/10/27.
//
//

#import "RongCloudPlugin.h"
#import <RongIMKit/RongIMKit.h>
#import "EAGLView.h"
#import "VTChatListViewController.h"
#import "VTConversationViewController.h"
#import "../../../Classes/Config.h"

@implementation RongCloudPlugin

- (void)start:(NSDictionary *)dict callid:(NSString *)callid callback:(void (^)(NSString *, NSString *))cb
{
    NSString *action = [dict valueForKey:@"action"];
    EAGLView *view = [EAGLView sharedEGLView];

    if([@"token" isEqualToString:action]){
        NSString *token = [dict valueForKey:@"token"];
        
        NSString *cacheToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"RONG_TOKEN"];
        
        if([token length] > 0 && ![token isEqualToString:cacheToken]){
            [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"RONG_TOKEN"];
            [[RCIMClient sharedRCIMClient] logout];
            [RongCloudPlugin checkConnect];
        }
        
    } else if([@"pchat" isEqualToString:action] || [@"gchat" isEqualToString:action]){
        
        NSString *title = [dict valueForKey:@"title"];
        NSString* userid = [dict valueForKey:@"token"];
        
        //新建一个聊天会话View Controller对象
        VTConversationViewController *chat = [[VTConversationViewController alloc]init];
        //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
        chat.targetId = userid;
        //设置聊天会话界面要显示的标题
        chat.title = title;
        if([@"pchat" isEqualToString:action]){
            //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
            chat.conversationType = ConversationType_PRIVATE;
        } else {
            chat.conversationType = ConversationType_GROUP;
        }
        
        //显示聊天会话界面
        [view.nav pushViewController:chat animated:YES];
    } else if([@"chatlist" isEqualToString:action]){
        VTChatListViewController *list = [[VTChatListViewController alloc] init];
        [view.nav pushViewController:list animated:YES];
    }
}

+ (void) checkConnect
{
    RCConnectionStatus state = [[RCIM sharedRCIM] getConnectionStatus];
    if(state == ConnectionStatus_Unconnected || state == ConnectionStatus_SignUp ||
       state == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT){
        NSString *cacheToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"RONG_TOKEN"];
        if(!cacheToken){
            NSLog(@"token 不存在");
            return;
        }
        
        [[RCIM sharedRCIM] connectWithToken:cacheToken success:^(NSString *userId) {
            NSLog(@"登陆成功。当前登录的用户ID：%@", userId);
            dispatch_async(dispatch_get_main_queue(), ^{
                Configs::getInstance()->postIMEnterSuccess(true);
            });
        } error:^(RCConnectErrorCode status) {
            NSLog(@"登陆的错误码为:%d", (int)status);
            dispatch_async(dispatch_get_main_queue(), ^{
                Configs::getInstance()->postIMEnterSuccess(false);
            });
        } tokenIncorrect:^{
            //token过期或者不正确。
            //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
            //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
            NSLog(@"token错误");
        }];
    }
}

+ (void) jumpToRYController:(NSDictionary *)dict
{
    NSString *ctype = [dict valueForKey:@"cType"];
    NSString *tId = [dict valueForKey:@"tId"];
    
    //新建一个聊天会话View Controller对象
    VTConversationViewController *chat = [[VTConversationViewController alloc]init];
    //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
    chat.targetId = tId;
    if([ctype isEqualToString:@"PR"]){
        //设置会话的类型，如单聊、讨论组、群聊、聊天室、客服、公众服务会话等
        chat.conversationType = ConversationType_PRIVATE;
    } else {
        chat.conversationType = ConversationType_GROUP;
    }
    
    //显示聊天会话界面
    EAGLView *view = [EAGLView sharedEGLView];
    [view.nav pushViewController:chat animated:YES];
    
}

@end
