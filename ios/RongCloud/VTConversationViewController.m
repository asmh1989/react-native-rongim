//
//  VTConversationViewController.m
//  Smobiler
//
//  Created by sun on 2016/10/31.
//
//

#import "VTConversationViewController.h"
#import "RongCloudPlugin.h"
#import "RCDUIBarButtonItem.h"
#import "RCDPrivateSettingsTableViewController.h"
#import "RCDGroupSettingsTableViewController.h"

@interface VTConversationViewController ()
@property(nonatomic, strong) RCGroup *groupInfo;
@end

@implementation VTConversationViewController

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
        [RongCloudPlugin checkConnect];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enableSaveNewPhotoToLocalSystem = YES;
    
    if (self.conversationType == ConversationType_GROUP){
        [self setRightNavigationItem:[UIImage imageNamed:@"Group_Setting"] withFrame:CGRectMake(10,3.5,21,19.5)];
    } else {
        [self setRightNavigationItem:[UIImage imageNamed:@"Private_Setting"] withFrame:CGRectMake(15,3.5,16,18.5)];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearHistoryMSG:)
                                                 name:@"ClearHistoryMsg"
                                               object:nil];
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

- (void)setRightNavigationItem:(UIImage *)image withFrame:(CGRect)frame {
    RCDUIBarButtonItem *rightBtn =
    [[RCDUIBarButtonItem alloc] initContainImage:image
                                  imageViewFrame:frame
                                     buttonTitle:nil
                                      titleColor:nil
                                      titleFrame:CGRectZero
                                     buttonFrame:CGRectMake(0, 0, 25, 25)
                                          target:self
                                          action:@selector(rightBarButtonItemClicked:)];
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)rightBarButtonItemClicked:(id)sender {
    if (self.conversationType == ConversationType_PRIVATE)
    {
        UIStoryboard *secondStroyBoard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDPrivateSettingsTableViewController *settingsVC =
        [secondStroyBoard instantiateViewControllerWithIdentifier:
         @"RCDPrivateSettingsTableViewController"];
        settingsVC.userId = self.targetId;
        
        [self.navigationController pushViewController:settingsVC animated:YES];
    }
    else if (self.conversationType == ConversationType_GROUP) {
        UIStoryboard *secondStroyBoard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        RCDGroupSettingsTableViewController *settingsVC =
        [secondStroyBoard instantiateViewControllerWithIdentifier:
         @"RCDGroupSettingsTableViewController"];
        settingsVC.groupId = self.targetId;
        
        [self.navigationController pushViewController:settingsVC animated:YES];
    }
}

- (void)clearHistoryMSG:(NSNotification *)notification {
    [self.conversationDataRepository removeAllObjects];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.conversationMessageCollectionView reloadData];
    });
}
@end
