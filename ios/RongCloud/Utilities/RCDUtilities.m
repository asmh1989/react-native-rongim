//
//  RCDUtilities.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/7/21.
//  Copyright (c) 2015年 RongCloud. All rights reserved.
//

#import "RCDUtilities.h"
#import "DefaultPortraitView.h"
#import "pinyin.h"

@implementation RCDUtilities
+ (UIImage *)imageNamed:(NSString *)name ofBundle:(NSString *)bundleName {
  UIImage *image = nil;
  NSString *image_name = [NSString stringWithFormat:@"%@.png", name];
  NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
  NSString *bundlePath =
      [resourcePath stringByAppendingPathComponent:bundleName];
  NSString *image_path = [bundlePath stringByAppendingPathComponent:image_name];

  // NSString* path = [[[[NSBundle mainBundle] resourcePath]
  // stringByAppendingPathComponent:bundleName]stringByAppendingPathComponent:[NSString
  // stringWithFormat:@"%@.png",name]];

  // image = [UIImage imageWithContentsOfFile:image_path];
  image = [[UIImage alloc] initWithContentsOfFile:image_path];
  return image;
}

+ (NSString *)defaultGroupPortrait:(RCGroup *)groupInfo {
  NSString *filePath = [[self class]
      getIconCachePath:[NSString
                           stringWithFormat:@"group%@.png", groupInfo.groupId]];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
    return [portraitPath absoluteString];
  } else {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:groupInfo.groupId
                             Nickname:groupInfo.groupName];
    UIImage *portrait = [defaultPortrait imageFromView];

    BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath
                                                       atomically:YES];
    if (result) {
      NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
      return [portraitPath absoluteString];
    } else {
      return nil;
    }
  }
}

+ (NSString *)defaultUserPortrait:(RCUserInfo *)userInfo {
  NSString *filePath = [[self class]
      getIconCachePath:[NSString
                           stringWithFormat:@"user%@.png", userInfo.userId]];
  if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
    return [portraitPath absoluteString];
  } else {
    DefaultPortraitView *defaultPortrait =
        [[DefaultPortraitView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [defaultPortrait setColorAndLabel:userInfo.userId Nickname:userInfo.name];
    UIImage *portrait = [defaultPortrait imageFromView];

    BOOL result = [UIImagePNGRepresentation(portrait) writeToFile:filePath
                                                       atomically:YES];
    if (result) {
      NSURL *portraitPath = [NSURL fileURLWithPath:filePath];
      return [portraitPath absoluteString];
    } else {
      return nil;
    }
  }
}

+ (NSString *)getIconCachePath:(NSString *)fileName {
  NSString *cachPath = [NSSearchPathForDirectoriesInDomains(
      NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *filePath =
      [cachPath stringByAppendingPathComponent:
                    [NSString stringWithFormat:@"CachedIcons/%@",
                                               fileName]]; // 保存文件的名称

  NSString *dirPath = [cachPath
      stringByAppendingPathComponent:[NSString
                                         stringWithFormat:@"CachedIcons"]];
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:dirPath]) {
    [fileManager createDirectoryAtPath:dirPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:nil];
  }
  return filePath;
}

/**
 *  汉字转拼音
 *
 *  @param hanZi 汉字
 *
 *  @return 转换后的拼音
 */
+ (NSString *)hanZiToPinYinWithString:(NSString *)hanZi {
  if (!hanZi) {
    return nil;
  }
  NSString *pinYinResult = [NSString string];
  for (int j = 0; j < hanZi.length; j++) {
    NSString *singlePinyinLetter = [[NSString
                                     stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])]
                                    uppercaseString];
    pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
  }
  return pinYinResult;
}

+ (NSString *)getFirstUpperLetter:(NSString *)hanzi {
  NSString *pinyin = [self hanZiToPinYinWithString:hanzi];
  NSString *firstUpperLetter = [[pinyin substringToIndex:1] uppercaseString];
  if ([firstUpperLetter compare:@"A"] != NSOrderedAscending &&
      [firstUpperLetter compare:@"Z"] != NSOrderedDescending) {
    return firstUpperLetter;
  } else {
    return @"#";
  }
}

+ (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)userList {
  if (!userList)
    return nil;
  NSArray *_keys = @[
                     @"A",
                     @"B",
                     @"C",
                     @"D",
                     @"E",
                     @"F",
                     @"G",
                     @"H",
                     @"I",
                     @"J",
                     @"K",
                     @"L",
                     @"M",
                     @"N",
                     @"O",
                     @"P",
                     @"Q",
                     @"R",
                     @"S",
                     @"T",
                     @"U",
                     @"V",
                     @"W",
                     @"X",
                     @"Y",
                     @"Z",
                     @"#"
                     ];
  
  NSMutableDictionary *infoDic = [NSMutableDictionary new];
  NSMutableArray *_tempOtherArr = [NSMutableArray new];
  BOOL isReturn = NO;
  
  for (NSString *key in _keys) {
    
    if ([_tempOtherArr count]) {
      isReturn = YES;
    }
    NSMutableArray *tempArr = [NSMutableArray new];
    for (id user in userList) {
      NSString *firstLetter;
    if ([user isMemberOfClass:[RCUserInfo class]]) {
      RCUserInfo *userInfo = (RCUserInfo*)user;
      if (userInfo.name.length > 0 && ![userInfo.name isEqualToString:@""]) {
        firstLetter = [self getFirstUpperLetter:userInfo.name];
      } else {
        firstLetter = [self getFirstUpperLetter:userInfo.name];
      }
    }
    if ([user isMemberOfClass:[RCUserInfo class]]) {
      RCUserInfo *userInfo = (RCUserInfo*)user;
      firstLetter = [self getFirstUpperLetter:userInfo.name];
    }
      if ([firstLetter isEqualToString:key]) {
        [tempArr addObject:user];
      }
      
      if (isReturn)
        continue;
      char c = [firstLetter characterAtIndex:0];
      if (isalpha(c) == 0) {
        [_tempOtherArr addObject:user];
      }
    }
    if (![tempArr count])
      continue;
    [infoDic setObject:tempArr forKey:key];
  }
  if ([_tempOtherArr count])
    [infoDic setObject:_tempOtherArr forKey:@"#"];
  
  NSArray *keys = [[infoDic allKeys]
             sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
               
               return [obj1 compare:obj2 options:NSNumericSearch];
             }];
  NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:keys];
  
  NSMutableDictionary *resultDic = [NSMutableDictionary new];
  [resultDic setObject:infoDic forKey:@"infoDic"];
  [resultDic setObject:allKeys forKey:@"allKeys"];
  return resultDic;
}

@end
