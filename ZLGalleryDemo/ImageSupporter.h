//
//  ImageSupporter.h
//  ZLGalleryDemo
//
//  Created by Doan Van Vu on 10/6/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageSupporter : NSObject

#pragma mark - singleton
+ (instancetype)sharedInstance;

#pragma mark - resizeImage
- (UIImage *)resizeImageToFit:(UIImage *)image;

#pragma mark - resizeImageToFit
- (void)resizeImageToFit:(UIImage *)image completion:(void(^)(UIImage *))completion;

#pragma mark - getImageFromFoder
- (void)getImageFromFolder:(NSString *)imageName completion:(void(^)(UIImage* image))compeltion;

#pragma mark - storeImageToDirectory
- (void)storeImageToFolder:(UIImage *)image withImageName:(NSString *)imageName;

#pragma mark - removeImageFromFolder
- (void)removeImageFromFolder:(NSString *)imageName;

#pragma mark - removeAllFromFolder
- (void)removeAllFromFolder;

@end
