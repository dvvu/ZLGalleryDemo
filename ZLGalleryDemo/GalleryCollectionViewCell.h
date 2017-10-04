//
//  GalleryCollectionViewCell.h
//  ZLGalleryDemo
//
//  Created by Doan Van Vu on 10/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GalleryCollectionViewCellObject.h"
#import <UIKit/UIKit.h>

@interface GalleryCollectionViewCell : UICollectionViewCell

@property (nonatomic) id<GalleryCollectionViewCellObjectProtocol> model;
@property (nonatomic) UIImageView* galaryImageView;
@property (nonatomic) NSString* identifier;

@end
