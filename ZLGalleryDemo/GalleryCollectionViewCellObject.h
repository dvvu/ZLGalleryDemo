//
//  GalleryCollectionViewCellObject.h
//  ZLGalleryDemo
//
//  Created by Doan Van Vu on 10/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "MediaItem.h"

@protocol GalleryCollectionViewCellObjectProtocol <NSObject>

@property (readonly, nonatomic, copy) NSString* identifier;
@property (readonly, nonatomic, assign) MediaType mediaType;
@property (readonly, nonatomic, assign) double videoDuration;

@end

@interface GalleryCollectionViewCellObject : NSObject <GalleryCollectionViewCellObjectProtocol>

@property (nonatomic, copy) NSString* identifier;
@property (nonatomic) double videoDuration;
@property (nonatomic) MediaType mediaType;

- (void)getImageCacheForCell:(UICollectionViewCell *)cell;

@end
