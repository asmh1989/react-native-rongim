//
//  VTChatListViewController.m
//  Smobiler
//
//  Created by sun on 2016/10/31.
//
//

#import "VTChatListViewController.h"
#import "VTConversationViewController.h"

#import "RongCloudPlugin.h"


@interface VTChatListViewController ()
{
}

@end

@implementation VTChatListViewController

//支持旋转
-(BOOL)shouldAutorotate{
    return YES;
}

//竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//一开始屏幕的方向
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"会话列表";
        [RongCloudPlugin checkConnect];
    }
    return self;
}

- (void)viewDidLoad {
    //重写显示相关的接口，必须先调用super，否则会屏蔽SDK默认的处理
    [super viewDidLoad];
    
    //设置需要显示哪些类型的会话
    [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),
                                        @(ConversationType_DISCUSSION),
                                        @(ConversationType_CHATROOM),
                                        @(ConversationType_GROUP),
                                        @(ConversationType_APPSERVICE),
                                        @(ConversationType_SYSTEM)]];
    //设置需要将哪些类型的会话在会话列表中聚合显示
    [self setCollectionConversationType:@[@(ConversationType_DISCUSSION)]];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置tableView样式
    self.conversationListTableView.separatorColor = [UIColor colorWithRed:208.0/255 green:208.0/255 blue:208.0/255 alpha:1.0f];
    self.conversationListTableView.tableFooterView = [UIView new];
    
    // 设置在NavigatorBar中显示连接中的提示
    self.showConnectingStatusOnNavigatorBar = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [RongCloudPlugin checkConnect];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark 点击事件的回调
/*!
 点击会话列表中Cell的回调
 
 @param conversationModelType   当前点击的会话的Model类型
 @param model                   当前点击的会话的Model
 @param indexPath               当前会话在列表数据源中的索引值
 
 @discussion 您需要重写此点击事件，跳转到指定会话的聊天界面。
 如果点击聚合Cell进入具体的子会话列表，在跳转时，需要将isEnteredToCollectionViewController设置为YES。
 */
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath
{
    //新建一个聊天会话View Controller对象
    VTConversationViewController *chat = [[VTConversationViewController alloc]init];
    //设置会话的目标会话ID。（单聊、客服、公众服务会话为对方的ID，讨论组、群聊、聊天室为会话的ID）
    chat.targetId = model.targetId;
    //设置聊天会话界面要显示的标题
    chat.title = model.conversationTitle;
    chat.conversationType = model.conversationType;
    
    //显示聊天会话界面
    [self.navigationController pushViewController:chat animated:YES];
}

/*!
 点击Cell头像的回调
 
 @param model   会话Cell的数据模型
 */
- (void)didTapCellPortrait:(RCConversationModel *)model
{
    
}

/*!
 长按Cell头像的回调
 
 @param model   会话Cell的数据模型
 */
- (void)didLongPressCellPortrait:(RCConversationModel *)model
{
    
}

@end
