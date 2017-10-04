//
//  GalaryCollectionViewDataSource.h
//  GalaryDemo
//
//  Created by Doan Van Vu on 10/1/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GalleryCollectionViewCellObject.h"
#import "Foundation/Foundation.h"
#import <UIKit/UIKit.h>
#import "MediaItem.h"

@interface GalleryCollectionViewDataSource : NSObject

#pragma mark - initWithCollectionView
- (instancetype)initWithCollectionView:(UICollectionView *)collectionView;

#pragma mark - setupData
- (void)setupData:(NSArray *)mediaItems;

@end
