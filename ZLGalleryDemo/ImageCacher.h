//
//  ImageCacher.h
//  GalaryDemo
//
//  Created by Doan Van Vu on 10/3/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageCacher : NSObject

#pragma mark - singleton
+ (instancetype)sharedInstance;

#pragma mark - set image to cache for key
- (void)setImageForKey:(UIImage *)image forKey:(NSString *)key;

#pragma mark - get image from cache with key
- (void)getImageForKey:(NSString *)key completionWith:(void(^)(UIImage* image))completion;

#pragma mark - removeImageForKey
- (void)removeImageForKey:(NSString *)key completionWith:(void(^)())completion;

- (void)reduceMemory;

@end
