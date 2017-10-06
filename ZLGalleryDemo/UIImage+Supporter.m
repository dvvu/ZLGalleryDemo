//
//  UIImage+Supporter.m
//  ZLGalleryDemo
//
//  Created by Doan Van Vu on 10/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "UIImage+Supporter.h"
#import "Constants.h"

@implementation UIImage (Supporter)

#pragma mark - resizeImage

- (UIImage *)resizeImageToFit {
    
    UIImage* image = self;
    
    CGAffineTransform scaleTransform;
    CGPoint origin;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    if (imageWidth > imageHeight) {
        
        CGFloat scaleRatio = IMAGE_SIZE / imageHeight;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(-(imageWidth - imageHeight) / 2, 0);
    } else {
        
        CGFloat scaleRatio = IMAGE_SIZE / imageWidth;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(0, -(imageHeight - imageWidth) / 2);
    }
    
    CGSize size = CGSizeMake(IMAGE_SIZE, IMAGE_SIZE);
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
