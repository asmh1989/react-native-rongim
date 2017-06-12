//
//  RCDGroupSettingsTableViewController.h
//  RCloudMessage
//
//  Created by Jue on 16/3/22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import <UIKit/UIKit.h>
#import "RCDBaseSettingTableViewCell.h"

@interface RCDGroupSettingsTableViewController
    : UITableViewController <UICollectionViewDataSource,
                             UICollectionViewDelegate, UIActionSheetDelegate,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate,RCDBaseSettingTableViewCellDelegate>

+ (instancetype)groupSettingsTableViewController;

@property(nonatomic, strong) NSString *groupId;

@property(nonatomic, strong) NSMutableArray *GroupMemberList;

@end
