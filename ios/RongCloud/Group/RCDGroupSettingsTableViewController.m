//
//  RCDGroupSettingsTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupSettingsTableViewController.h"
#import "DefaultPortraitView.h"
#import "RCDCommonDefine.h"
#import "RCDConversationSettingTableViewHeaderItem.h"
#import "RCDGroupMembersTableViewController.h"
#import <RongIMLib/RongIMLib.h>
#import "UIColor+RCColor.h"
#import "RCDRCIMDataSource.h"
#import "VTConversationViewController.h"

static NSString *CellIdentifier = @"RCDBaseSettingTableViewCell";

#define SwitchButtonTag  1111

@interface RCDGroupSettingsTableViewController ()
@end

@implementation RCDGroupSettingsTableViewController {
    NSInteger numberOfSections;
    RCConversation *currentConversation;
    BOOL enableNotification;
    NSMutableArray *collectionViewResource;
    UICollectionView *headerView;
    UIImage *image;
    NSData *data;
    RCGroup *Group;
}

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

+ (instancetype)groupSettingsTableViewController {
    return [[[self class] alloc]init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = HEXCOLOR(0xf0f0f6);
    self.tableView.separatorColor = HEXCOLOR(0xdfdfdf);
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation
    // bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    numberOfSections = 0;
    
    CGRect tempRect = CGRectMake(
                                 0, 0, [UIScreen mainScreen].bounds.size.width,
                                 headerView.collectionViewLayout.collectionViewContentSize.height);
    UICollectionViewFlowLayout *flowLayout =
    [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    headerView = [[UICollectionView alloc] initWithFrame:tempRect
                                    collectionViewLayout:flowLayout];
    headerView.delegate = self;
    headerView.dataSource = self;
    headerView.scrollEnabled = NO;
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView registerClass:[RCDConversationSettingTableViewHeaderItem class]
   forCellWithReuseIdentifier:@"RCDConversationSettingTableViewHeaderItem"];
    
    [self startLoad];
    self.title = @"群组信息";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 本类的私有方法
- (void)clickNotificationBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient]
     setConversationNotificationStatus:ConversationType_GROUP
     targetId:self.groupId
     isBlocked:swch.on
     success:^(RCConversationNotificationStatus nStatus) {
         NSLog(@"成功");
         
     }
     error:^(RCErrorCode status) {
         NSLog(@"失败");
     }];
}

- (void)clickIsTopBtn:(id)sender {
    UISwitch *swch = sender;
    [[RCIMClient sharedRCIMClient] setConversationToTop:ConversationType_GROUP
                                               targetId:self.groupId
                                                  isTop:swch.on];
}

- (void)startLoad {
    currentConversation =
    [[RCIMClient sharedRCIMClient] getConversation:ConversationType_GROUP
                                          targetId:self.groupId];
    if (currentConversation.targetId == nil) {
        numberOfSections = 2;
        [self.tableView reloadData];
    } else {
        numberOfSections = 3;
        [[RCIMClient sharedRCIMClient]
         getConversationNotificationStatus:ConversationType_GROUP
         targetId:self.groupId
         success:^(RCConversationNotificationStatus nStatus) {
             enableNotification = NO;
             if (nStatus == NOTIFY) {
                 enableNotification = YES;
             }
             [self.tableView reloadData];
         }
         error:^(RCErrorCode status){
             
         }];
    }
    
    [[RCDRCIMDataSource shareInstance]
     getGroupInfoWithGroupId:self.groupId
     completion:^(RCGroup *group) {
          Group = group;
     }];
    
    [[RCDRCIMDataSource shareInstance]
     getAllMembersOfGroup:self.groupId
     result:^(NSArray<NSString *> *userIdList) {
         if ([userIdList count] > 0) {
             
             _GroupMemberList = [NSMutableArray new];
             for (NSString *user in userIdList) {
                 [[RCDRCIMDataSource shareInstance]
                  getUserInfoWithUserId:user
                  completion:^(RCUserInfo *userInfo) {
                      [_GroupMemberList addObject:userInfo];
                  }];
             }
         }
    }];
    
    if ([_GroupMemberList count] > 0) {
        /******************添加headerview*******************/
        collectionViewResource =
        [[NSMutableArray alloc] initWithArray:_GroupMemberList];
        [self setHeaderView];
    }
}

- (void)buttonChatAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)scaleImage:(UIImage *)Image toScale:(float)scaleSize {
    UIGraphicsBeginImageContext(
                                CGSizeMake(Image.size.width * scaleSize, Image.size.height * scaleSize));
    [Image drawInRect:CGRectMake(0, 0, Image.size.width * scaleSize,
                                 Image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)clearCacheAlertMessage:(NSString *)msg {
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:nil
                               message:msg
                              delegate:nil
                     cancelButtonTitle:@"确定"
                     otherButtonTitles:nil, nil];
    [alertView show];
}


#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 100) {
        if (buttonIndex == 0) {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            RCDBaseSettingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UIActivityIndicatorView *activityIndicatorView =
            [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            float cellWidth = cell.bounds.size.width;
            UIView *loadingView = [[UIView alloc]initWithFrame:CGRectMake(cellWidth - 50, 10, 40, 40)];
            [loadingView addSubview:activityIndicatorView];
            dispatch_async(dispatch_get_main_queue(), ^{
                [activityIndicatorView startAnimating];
                [cell addSubview:loadingView];
            });
            
            [[RCIMClient sharedRCIMClient]deleteMessages:ConversationType_GROUP targetId:self.groupId success:^{
                [self performSelectorOnMainThread:@selector(clearCacheAlertMessage:)
                                       withObject:@"清除聊天记录成功！"
                                    waitUntilDone:YES];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"ClearHistoryMsg" object:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loadingView removeFromSuperview];
                });
                
            } error:^(RCErrorCode status) {
                [self performSelectorOnMainThread:@selector(clearCacheAlertMessage:)
                                       withObject:@"清除聊天记录失败！"
                                    waitUntilDone:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loadingView removeFromSuperview];
                });
            }];
            
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (numberOfSections > 0) {
        return numberOfSections;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = 2;
            break;
            
        case 2:
            rows = 3;
            break;
            
        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCDBaseSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    static NSString *cellIndeti = @"baseCell";
    RCDBaseSettingTableViewCell *__cell = [tableView dequeueReusableCellWithIdentifier:cellIndeti];
    
    if(!cell){
        cell = [[RCDBaseSettingTableViewCell alloc]init];
    }
    if(!__cell) {
        __cell = [[RCDBaseSettingTableViewCell alloc]initWithLeftImage:nil leftImageSize:CGSizeZero rightImae:[UIImage imageNamed:@"icon_person"] rightImageSize:CGSizeMake(25, 25)];
        __cell.tag = 1000;
    }
    
    if (indexPath.section == 0) {
        [cell setCellStyle:DefaultStyle];
        cell.leftLabel.text = [NSString stringWithFormat:@"全部群成员(%d)", (int)[_GroupMemberList count]];
    }else if(indexPath.section == 1){
        switch (indexPath.row) {
            case 0:
                [__cell setCellStyle:DefaultStyle];
                __cell.leftLabel.text = @"群组头像";
                if ([Group.portraitUri isEqualToString:@""]) {
                    DefaultPortraitView *defaultPortrait = [[DefaultPortraitView alloc]
                                                            initWithFrame:CGRectMake(0, 0, 100, 100)];
                    [defaultPortrait setColorAndLabel:self.groupId Nickname:Group.groupName];
                    UIImage *portrait = [defaultPortrait imageFromView];
                    __cell.rightImageView.image = portrait;
                } else {
                    //开辟一个子线程，执行耗时的代码
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSData* imagedata=[NSData dataWithContentsOfURL:[NSURL URLWithString:Group.portraitUri]];
                        UIImage *portraitimage=[UIImage imageWithData:imagedata];
                        //待子线程里面的图片加载完成，回到主线程更新界面
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (portraitimage) {
                                __cell.rightImageView.image=portraitimage;
                            }else{
                                __cell.rightImageView.image = [UIImage imageNamed:@"icon_person"];
                            }
                        });
                    });
                }
                __cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return __cell;
                break;
            case 1:
                [cell setCellStyle:DefaultStyle_RightLabel];
                cell.leftLabel.text = @"群组名称";
                cell.rightLabel.text = Group.groupName;
                break;
            default:
                break;
        }
    }else {
        switch (indexPath.row) {
            case 0:
                [cell setCellStyle:SwitchStyle];
                cell.leftLabel.text = @"消息免打扰";
                cell.switchButton.on = !enableNotification;
                cell.switchButton.tag = SwitchButtonTag;
                break;
            case 1:
                [cell setCellStyle:SwitchStyle];
                cell.leftLabel.text = @"会话置顶";
                cell.switchButton.on = currentConversation.isTop;
                cell.switchButton.tag = SwitchButtonTag + 1;
                break;
            case 2:
                [cell setCellStyle:DefaultStyle];
                cell.leftLabel.text= @"清除聊天记录";
                break;
            default:
                break;
        }
    }
    
    cell.baseSettingTableViewDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 14.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            RCDGroupMembersTableViewController *GroupMembersVC =
            [[RCDGroupMembersTableViewController alloc] init];
            GroupMembersVC.GroupMembers =_GroupMemberList;
            [self.navigationController pushViewController:GroupMembersVC animated:YES];
        }
            break;

        case 2:
        {
            switch (indexPath.row) {
                case 2:
                {
                    UIActionSheet *actionSheet =
                    [[UIActionSheet alloc] initWithTitle:@"确定清除聊天记录？"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"确定"
                                       otherButtonTitles:nil];
                    
                    [actionSheet showInView:self.view];
                    actionSheet.tag = 100;
                }break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = 55;
    float height = width + 15 + 9;
    
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    UICollectionViewFlowLayout *flowLayout =
    (UICollectionViewFlowLayout *)collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 20;
    flowLayout.minimumLineSpacing = 12;
    return UIEdgeInsetsMake(15, 10, 10, 10);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [collectionViewResource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCDConversationSettingTableViewHeaderItem *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:
     @"RCDConversationSettingTableViewHeaderItem"
                                              forIndexPath:indexPath];
    
    if (collectionViewResource.count > 0) {
        if (![collectionViewResource[indexPath.row]
              isKindOfClass:[UIImage class]]) {
            RCUserInfo *user = collectionViewResource[indexPath.row];
            if ([user.userId isEqualToString:[RCIMClient sharedRCIMClient]
                 .currentUserInfo.userId]) {
                [cell.btnImg setHidden:YES];
            }
            [cell setUserModel:user];
        } else {
            UIImage *Image = collectionViewResource[indexPath.row];
            cell.ivAva.image = nil;
            cell.ivAva.image = Image;
            cell.titleLabel.text = @"";
            
        }
    }
    cell.ivAva.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCUserInfo *user = [_GroupMemberList objectAtIndex:indexPath.row];
    
    VTConversationViewController *chat = [[VTConversationViewController alloc]init];
    chat.targetId = user.userId;
    chat.title = user.name;
    chat.conversationType = ConversationType_PRIVATE;
    
    [self.navigationController pushViewController:chat animated:YES];
}

- (void)limitDisplayMemberCount {
    if ([collectionViewResource count] > 19) {
        NSRange rang = NSMakeRange(19, [collectionViewResource count] - 19);
        [collectionViewResource removeObjectsInRange:rang];
    }
}

-(void)showAlert:(NSString *)alertContent
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertContent delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)setHeaderView
{
    [self limitDisplayMemberCount];

    [headerView reloadData];
    headerView.frame = CGRectMake(
                                  0, 0, [UIScreen mainScreen].bounds.size.width,
                                  headerView.collectionViewLayout.collectionViewContentSize.height);
    CGRect frame = headerView.frame;
    frame.size.height += 14;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];
    self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    [self.tableView.tableHeaderView addSubview:headerView];
}

#pragma mark - RCDBaseSettingTableViewCellDelegate
- (void)onClickSwitchButton:(id)sender {
    UISwitch *switchBtn = (UISwitch *)sender;
    //如果是“消息免打扰”的switch点击
    if(switchBtn.tag == SwitchButtonTag){
        [self clickNotificationBtn:sender];
    }else { //否则是“会话置顶”的switch点击
        [self clickIsTopBtn:sender];
    }
}
@end
