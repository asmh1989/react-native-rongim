
#import "SMOSmRongim.h"

@implementation SMOSmRongim

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()


      
RCT_EXPORT_METHOD(token:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback)
{
  //token 实现, 需要回传结果用callback(@[XXX]), 数组参数里面就一个NSDictionary元素即可
}
      
RCT_EXPORT_METHOD(pchat:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback)
{
  //pchat 实现, 需要回传结果用callback(@[XXX]), 数组参数里面就一个NSDictionary元素即可
}
      
RCT_EXPORT_METHOD(gchat:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback)
{
  //gchat 实现, 需要回传结果用callback(@[XXX]), 数组参数里面就一个NSDictionary元素即可
}
      
RCT_EXPORT_METHOD(chatlist:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback)
{
  //chatlist 实现, 需要回传结果用callback(@[XXX]), 数组参数里面就一个NSDictionary元素即可
}

@end
  