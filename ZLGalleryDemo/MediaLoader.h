//
//  MediaLoader.h
//  GalaryDemo
//
//  Created by Doan Van Vu on 10/2/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ThreadSafeForMutableArray.h"
#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface MediaLoader : NSObject

#pragma mark public class
+ (instancetype)sharedInstance;

#pragma mark - checkPermissionPhoto
- (void)checkPermission:(void(^)(NSError *))completion;

#pragma mark - getMediaItems
- (void)getMediaItems:(void(^)(NSArray *))completion;

@end
