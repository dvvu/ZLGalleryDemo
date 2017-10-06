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
#import "Constants.h"

@interface MediaLoader : NSObject

#pragma mark public class
+ (instancetype)sharedInstance;

#pragma mark - requestAuthorization
- (void)requestAuthCallbackQueue:(dispatch_queue_t)queue completion:(void(^)(BOOL granted, MediaAuthStatus))completion;

#pragma mark - checkPermission
- (MediaAuthStatus)checkPermission;

#pragma mark - getMediaItems
- (void)getMediaItemsCallbackQueue:(dispatch_queue_t)queue completion:(void(^)(NSArray* mediaItmes, NSError *))completion;

@end
