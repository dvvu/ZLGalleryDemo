//
//  GalaryCollectionViewDataSource.m
//  GalaryDemo
//
//  Created by Doan Van Vu on 10/1/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GalleryCollectionViewDataSource.h"
#import "ThreadSafeForMutableArray.h"
#import "GalleryCollectionViewCell.h"
#import <Photos/Photos.h>

@interface GalleryCollectionViewDataSource () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) ThreadSafeForMutableArray* mediaItems;
@property (nonatomic) UICollectionView* collectionView;
@property (nonatomic) dispatch_queue_t loaderItemsQueue;

@end

@implementation GalleryCollectionViewDataSource

#pragma mark - initWithCollectionView

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView {
    
    if (self = [super init]) {
        
        _mediaItems = [[ThreadSafeForMutableArray alloc] init];
        _loaderItemsQueue = dispatch_queue_create("LOADER_ITEMS_QUEUE", DISPATCH_QUEUE_SERIAL);
        _collectionView = collectionView;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[GalleryCollectionViewCell class] forCellWithReuseIdentifier:@"GalleryCollectionViewCell"];
    }
    return self;
}

#pragma mark - setupData

- (void)setupData:(NSArray *)mediaItems {
    
    dispatch_async(_loaderItemsQueue, ^{
        
        [mediaItems enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL* stop) {
            
            MediaItem* item = (MediaItem *)object;
            
            GalleryCollectionViewCellObject* cellObject = [[GalleryCollectionViewCellObject alloc] init];
            cellObject.mediaType = item.mediaType;
            cellObject.identifier = item.identifier;
            cellObject.videoDuration = item.videoDuration;
            
            [_mediaItems addObject:cellObject];
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_collectionView reloadData];
        });
    });
}

#pragma mark - Overriden methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _mediaItems.count;
}

#pragma mark - cellForItemAtIndexPath

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GalleryCollectionViewCell* cell = (GalleryCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"GalleryCollectionViewCell" forIndexPath:indexPath];
    GalleryCollectionViewCellObject* model = [_mediaItems objectAtIndex:indexPath.item];
   
    if (cell.model != model) {
        
        cell.model = model;
        cell.identifier = model.identifier;
        [model getImageCacheForCell:cell];
    }

    return cell;
}

#pragma mark - collectionViewLayout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(3, 3, 3, 3);
}

#pragma mark - didSelectItemAtIndexPath

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%ld", (long)indexPath.row);
}

@end
