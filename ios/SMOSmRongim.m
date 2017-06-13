
#import "SMOSmRongim.h"

@interface SMOSmRongim (){
    NSString *mToken;
    NSString *
}

@end

@implementation SMOSmRongim

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()


      
RCT_EXPORT_METHOD(setToken:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback)
{
  //token 实现, 需要回传结果用callback(@[XXX]), 数组参数里面就一个NSDictionary元素即可
}
      
RCT_EXPORT_METHOD(openChat:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback)
{
  //pchat 实现, 需要回传结果用callback(@[XXX]), 数组参数里面就一个NSDictionary元素即可
}
 
RCT_EXPORT_METHOD(openChatlist:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback)
{
  //chatlist 实现, 需要回传结果用callback(@[XXX]), 数组参数里面就一个NSDictionary元素即可
}

@end
  
