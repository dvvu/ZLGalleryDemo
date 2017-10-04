//
//  GalleryCollectionViewCellObject.m
//  ZLGalleryDemo
//
//  Created by Doan Van Vu on 10/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GalleryCollectionViewCellObject.h"
#import "GalleryCollectionViewCell.h"
#import "UIImage+Supporter.h"
#import <Photos/Photos.h>
#import "ImageCacher.h"

@implementation GalleryCollectionViewCellObject

#pragma mark - getImageCacheForCell

- (void)getImageCacheForCell:(UICollectionViewCell *)cell {
    
    [[ImageCacher sharedInstance] getImageForKey:_identifier completionWith:^(UIImage* image) {
        
        __weak GalleryCollectionViewCell* galleryCollectionViewCell = (GalleryCollectionViewCell *)cell;
        
        if (image) {
            
            if ([_identifier isEqualToString:galleryCollectionViewCell.identifier]) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    galleryCollectionViewCell.galaryImageView.image = image;
                });
            }
        } else {
            
            [self requestImageFromAsset:_identifier completion:^(UIImage* image) {
                
                if(image) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        galleryCollectionViewCell.galaryImageView.image = image;
                    });
                    
                    [[ImageCacher sharedInstance] setImageForKey:[image resizeImage:100] forKey:_identifier];
                }
            }];
        }
    }];
}

#pragma mark - requestImageFromAsset

- (void)requestImageFromAsset:(NSString *)localIdentifier completion:(void(^)(UIImage *))completion {
    
    PHFetchResult* savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    
    [savedAssets enumerateObjectsUsingBlock:^(PHAsset* asset, NSUInteger idx, BOOL* stop) {
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage* _Nullable image, NSDictionary* _Nullable info) {
            
            NSLog(@"get image from result");
            
            if (completion) {
                
                completion(image);
            }
        }];
    }];
}

@end
