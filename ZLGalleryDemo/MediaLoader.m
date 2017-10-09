//
//  MediaLoader.m
//  GalaryDemo
//
//  Created by Doan Van Vu on 10/2/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageCacher.h"
#import "MediaLoader.h"
#import "MediaItem.h"
#import "Constants.h"

@interface MediaLoader ()

@property (nonatomic) ThreadSafeForMutableArray* mediaItems;
@property (nonatomic) dispatch_queue_t mediaLoaderQueue;
@property (nonatomic) BOOL isSupportiOS8;
@property (nonatomic) int maxloaderItems;

@end

@implementation MediaLoader

+ (instancetype)sharedInstance {
    
    static MediaLoader* sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[MediaLoader alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _maxloaderItems = 70;
        _isSupportiOS8 = iOS_VERSION_GREATER_THAN_OR_EQUAL_TO(8.0);
        _mediaItems = [[ThreadSafeForMutableArray alloc] init];
        _mediaLoaderQueue = dispatch_queue_create("MEDIA_LOADER_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - checkPermission

- (MediaAuthStatus)checkPermission {
    
    if (_isSupportiOS8) {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        switch (status) {
                
            case PHAuthorizationStatusAuthorized:
                
                return MediaAuthStatusAuthorized;
                break;
            case PHAuthorizationStatusDenied:
                
                return MediaAuthStatusDenied;
                break;
            case PHAuthorizationStatusNotDetermined:
                
                return MediaAuthStatusNotDetermined;
                break;
            case PHAuthorizationStatusRestricted:
                
                return MediaAuthStatusRestricted;
                break;
            default:
                
                return MediaAuthStatusNotDetermined;
                break;
        }
    } else {
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        
        switch (status) {
                
            case ALAuthorizationStatusAuthorized:
                
                return MediaAuthStatusAuthorized;
                break;
            case ALAuthorizationStatusDenied:
                
                return MediaAuthStatusDenied;
                break;
            case ALAuthorizationStatusNotDetermined:
                
                return MediaAuthStatusNotDetermined;
                break;
            case ALAuthorizationStatusRestricted:
                
                return MediaAuthStatusRestricted;
                break;
            default:
                
                return MediaAuthStatusNotDetermined;
                break;
        }
    }
}

#pragma mark - checkPHNotDeterminedPermission

- (void)requestAuthCallbackQueue:(dispatch_queue_t)queue completion:(void(^)(BOOL granted, MediaAuthStatus))completion {
    
    dispatch_queue_t callbackQueue = queue != nil ? queue : dispatch_get_main_queue();
    
     if (_isSupportiOS8) {
   
         [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
             
             if (status == PHAuthorizationStatusAuthorized) {
                 
                 dispatch_async(callbackQueue, ^ {
                     
                     if (completion) {
                         
                          completion(YES, MediaAuthStatusAuthorized);
                     }
                 });
             } else {
                 
                 dispatch_async(callbackQueue, ^ {
                     
                     if (completion) {
                         
                         completion(NO, MediaAuthStatusAuthorized);
                     }
                 });
             }
         }];
     } else {
         
         dispatch_async(callbackQueue, ^ {
             
             if (completion) {
                 
                 completion(YES, MediaAuthStatusAuthorized);
             }
         });
     }
}

#pragma mark - getMediaItems

- (void)getMediaItemsCallbackQueue:(dispatch_queue_t)queue completion:(void(^)(NSArray* mediaItmes, NSError *))completion {
    
    dispatch_queue_t callbackQueue = queue != nil ? queue : dispatch_get_main_queue();
    
    if (_isSupportiOS8) {
        
        [self getMediaItemsFromPHAsset:callbackQueue completion:^(NSArray* mediaItems, NSError* error) {
            
            if (completion) {
                
                completion(mediaItems, error);
            }
        }];
    } else {
        
        [self getMediaItemsFromAssetsLibrary:callbackQueue completion:^(NSArray* mediaItems, NSError* error) {
            
            if (completion) {
                
                completion(mediaItems, nil);
            }
        }];
    }
}

#pragma mark - getListMediaFromPHAsset
// call back array mediaItem. and error
- (void)getMediaItemsFromPHAsset:(dispatch_queue_t)callbackQueue completion:(void(^)(NSArray *, NSError *))completion {
    
    dispatch_async(_mediaLoaderQueue,^{
    
        PHFetchResult* assetsFetchResults = [PHAsset fetchAssetsWithOptions:nil];
        
        if (!assetsFetchResults.count) {
            
            dispatch_async(callbackQueue, ^ {
                
                if (completion) {
                    
                    completion(nil, nil);
                }
            });
        } else {
            
            if (assetsFetchResults.count < _maxloaderItems) {
                
                _maxloaderItems = (int)assetsFetchResults.count;
            }
            
            for (int i = 0; i < _maxloaderItems; i++) {
                
                PHAsset* asset = assetsFetchResults[i];
                
                [[MediaItem alloc] initWithPHAsset:asset completion:^(MediaItem* mediaItem) {
                    
                    if (!mediaItem) {
                        
                        _maxloaderItems--;
                    } else {
                        
                        [_mediaItems addObject:mediaItem];
                    }
                    
                    if (_maxloaderItems == _mediaItems.count) {
                        
                        NSArray* array = [_mediaItems sortedArrayUsingDescriptors:@"creationDate"];
                        
                        dispatch_async(callbackQueue, ^ {
                            
                            if (completion) {
                                
                                completion(array, nil);
                            }
                        });
                    }
                }];
            }
        }
    });
}

#pragma mark - getMediaItemsFromAssetsLibrary
// call back array mediaItem. and error
- (void)getMediaItemsFromAssetsLibrary:(dispatch_queue_t)callbackQueue completion:(void(^)(NSArray *, NSError *))completion {
    
    dispatch_async(_mediaLoaderQueue, ^ {
    
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        NSMutableArray* groups = [[NSMutableArray alloc] init];
        __block int assets = 0;
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup* group, BOOL* stop) {
            NSLog(@"%@",[group valueForProperty:ALAssetsGroupPropertyPersistentID]);
            
            if ([group valueForProperty:ALAssetsGroupPropertyPersistentID]) {
               
                [groups addObject:group];
                assets += (int)group.numberOfAssets;
            }
            
            if (group.numberOfAssets > 0) {
                
                if (_maxloaderItems > group.numberOfAssets) {
                    
                    _maxloaderItems = (int)group.numberOfAssets;
                }
                
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
                
                [group enumerateAssetsUsingBlock:^(ALAsset* asset, NSUInteger index, BOOL* stop) {
                    
                    [[MediaItem alloc] initWithALAsset:asset completion:^(MediaItem* mediaItem) {
                        
                        if (!mediaItem) {
                            
                            _maxloaderItems--;
                        } else {
                            
                            [_mediaItems addObject:mediaItem];
                        }
                        
                        if (_maxloaderItems == _mediaItems.count) {
                            
                            NSArray* array = [_mediaItems sortedArrayUsingDescriptors:@"creationDate"];
                            
                            dispatch_async(callbackQueue, ^ {
                                
                                if (completion) {
                                    
                                    completion(array, nil);
                                }
                            });
                            
                            return;
                        }
                    }];
                }];
            }
        } failureBlock:^(NSError* error) {
            
            NSLog(@"Error Description %@",[error description]);
           
            dispatch_async(callbackQueue, ^ {
                
                if (completion) {
                    
                    completion(nil, error);
                }
            });
        }];
    });
}

@end
