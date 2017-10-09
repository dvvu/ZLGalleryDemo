//
//  GalleryCollectionViewCellObject.m
//  ZLGalleryDemo
//
//  Created by Doan Van Vu on 10/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GalleryCollectionViewCellObject.h"
#import "GalleryCollectionViewCell.h"
#import "ImageSupporter.h"
#import <Photos/Photos.h>
#import "ImageCacher.h"
#import "MemoryCache.h"
#import "MediaLoader.h"

@implementation GalleryCollectionViewCellObject

#pragma mark - getImageCacheForCell

- (void)getImageCacheForCell:(UICollectionViewCell *)cell {
    
    __weak GalleryCollectionViewCell* galleryCollectionViewCell = (GalleryCollectionViewCell *)cell;
   
    [[ImageCacher sharedInstance] getImageForKey:_identifier completionWith:^(UIImage* image) {
        
        if (image) {
            
            if ([_identifier isEqualToString:galleryCollectionViewCell.identifier]) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    galleryCollectionViewCell.galaryImageView.image = image;
                });
            }
        } else {
            
            [[ImageSupporter sharedInstance] getImageFromFolder:_identifier completion:^(UIImage* image) {
                
                if (image) {
                  
                    if ([_identifier isEqualToString:galleryCollectionViewCell.identifier]) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            galleryCollectionViewCell.galaryImageView.image = image;
                            [[ImageCacher sharedInstance] setImageForKey:image forKey:_identifier];
                        });
                    }
                }
            }];
        }
    }];
}

#pragma mark - requestImageFromAsset

- (void)requestImageFromAsset:(NSString *)localIdentifier completion:(void(^)(UIImage *))completion {
    
    PHFetchResult* savedAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
    
    if (savedAssets) {
        
        [savedAssets enumerateObjectsUsingBlock:^(PHAsset* asset, NSUInteger idx, BOOL* stop) {
            
            if (asset) {
                
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(IMAGE_SIZE, IMAGE_SIZE) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage* _Nullable image, NSDictionary* _Nullable info) {
                    
                    NSLog(@"get image from result");
                    
                    if (completion) {
                        
                        completion(image);
                        return;
                    }
                }];
            }
        }];
    } else {
        
        if (completion) {
            
            completion(nil);
        }
    }
    
    savedAssets = nil;
}

@end
