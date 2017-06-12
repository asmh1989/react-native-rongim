//
//  RCDGroupMembersTableViewController.m
//  RCloudMessage
//
//  Created by Jue on 16/4/10.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDGroupMembersTableViewController.h"
#import "DefaultPortraitView.h"
#import "RCDContactTableViewCell.h"
#import <RongIMKit/RongIMKit.h>
#import "VTConversationViewController.h"

@interface RCDGroupMembersTableViewController ()

@end

@implementation RCDGroupMembersTableViewController

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

- (void)viewDidLoad {
  [super viewDidLoad];

  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;

  // Uncomment the following line to display an Edit button in the navigation
  // bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  self.tableView.tableFooterView = [UIView new];

  self.title = [NSString stringWithFormat:@"群成员(%lu)",
                                          (unsigned long)[_GroupMembers count]];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
  return [_GroupMembers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *reusableCellWithIdentifier = @"RCDContactTableViewCell";
  RCDContactTableViewCell *cell = [self.tableView
      dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
  if (cell == nil) {
    cell = [[RCDContactTableViewCell alloc] init];
  }
  // Configure the cell...
  RCUserInfo *user = _GroupMembers[indexPath.row];
  if ([user.portraitUri isEqualToString:@""]) {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:user.userId Nickname:user.name];
    UIImage *portrait = [defaultPortrait imageFromView];
    cell.portraitView.image = portrait;
  } else {
      //开辟一个子线程，执行耗时的代码
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          NSData* imagedata=[NSData dataWithContentsOfURL:[NSURL URLWithString:user.portraitUri]];
          UIImage *portraitimage=[UIImage imageWithData:imagedata];
          //待子线程里面的图片加载完成，回到主线程更新界面
          dispatch_async(dispatch_get_main_queue(), ^{
              if (portraitimage) {
                  cell.portraitView.image=portraitimage;
              }else{
                  cell.portraitView.image = [UIImage imageNamed:@"contact"];
              }
          });
      });
  }
  cell.portraitView.layer.masksToBounds = YES;
  cell.portraitView.layer.cornerRadius = 5.f;
  cell.portraitView.contentMode = UIViewContentModeScaleAspectFill;

  cell.nicknameLabel.font = [UIFont systemFontOfSize:15.f];
  cell.nicknameLabel.text = user.name;
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 70.0;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RCUserInfo *user = _GroupMembers[indexPath.row];

    VTConversationViewController *chat = [[VTConversationViewController alloc]init];
    chat.targetId = user.userId;
    chat.title = user.name;
    chat.conversationType = ConversationType_PRIVATE;

    [self.navigationController pushViewController:chat animated:YES];
}



@end
