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
    UIImage* image = [[ContactImageMemoryCache sharedInstance] objectForKey:_identifier];
    
    if (image) {
        
        if ([_identifier isEqualToString:galleryCollectionViewCell.identifier]) {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                galleryCollectionViewCell.galaryImageView.image = image;
            });
        }
    } else {
        
        [[ImageSupporter sharedInstance] getImageFromFolder:_identifier callbackQueue:dispatch_get_main_queue() completion:^(UIImage* image) {
            
            if (image) {
                
                if ([_identifier isEqualToString:galleryCollectionViewCell.identifier]) {
                    
                    galleryCollectionViewCell.galaryImageView.image = image;
                    [[ContactImageMemoryCache sharedInstance] addObject:image name:_identifier];
                }
            }
        }];
    }
}

@end
