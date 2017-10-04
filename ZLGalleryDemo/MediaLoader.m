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

@interface MediaLoader ()

@property (nonatomic) ThreadSafeForMutableArray* mediaItems;
@property (nonatomic) dispatch_queue_t photoPermissionQueue;
@property (nonatomic) dispatch_queue_t mediaLoaderQueue;
@property (nonatomic)  BOOL isSupportiOS8;
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
        _photoPermissionQueue = dispatch_queue_create("PHOTO_PERMISSION_QUEUE", DISPATCH_QUEUE_SERIAL);
    }
    
    return self;
}

#pragma mark - checkPermission

- (void)checkPermission:(void(^)(NSError *))completion {
    
    if (_isSupportiOS8) {
        
        [self checkPHAssetPermission:^(NSError* error) {
            
            if(completion) {
                
                completion(error);
            }
        }];
    } else {
        
        [self checkAssetsLibraryPermissions:^(NSError* error) {
           
            if(completion) {
                
                completion(error);
            }
        }];
    }
}

#pragma mark - getMediaItems

- (void)getMediaItems:(void(^)(NSArray *))completion {
    
    if (_isSupportiOS8) {
        
        [self getMediaItemsFromPHAsset:^(NSArray* mediaItems) {
            
            if (completion) {
                
                completion(mediaItems);
            }
        }];
    } else {
        
        [self getMediaItemsFromAssetsLibrary:^(NSArray* mediaItems) {
            
            if (completion) {
                
                completion(mediaItems);
            }
        }];
    }
}

#pragma mark - getListMediaFromPHAsset

- (void)getMediaItemsFromPHAsset:(void(^)(NSArray *))completion {
    
    dispatch_async(_mediaLoaderQueue,^{
    
        PHFetchResult* assetsFetchResults = [PHAsset fetchAssetsWithOptions:nil];
        
        if (_maxloaderItems > assetsFetchResults.count) {
            
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
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        if (completion) {
                            
                            completion(array);
                        }
                    });
                }
            }];
        }
    });
}

#pragma mark - checkPermissionPhoto

- (void)checkPHAssetPermission:(void(^)(NSError *))completion {
    
    dispatch_async(_photoPermissionQueue, ^ {
        
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        
        if (status == PHAuthorizationStatusAuthorized) {
            
            // Access has been granted.
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion(nil);
                });
            }
        } else if (status == PHAuthorizationStatusDenied) {
            
            // Access has been denied.
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion([NSError errorWithDomain:@"" code:PHAuthorizationStatusDenied userInfo:nil]);
                });
            }
        } else if (status == PHAuthorizationStatusNotDetermined) {
            
            // Access has not been determined.
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                
                if (status == PHAuthorizationStatusAuthorized) {
                    // Access has been granted.
                    if (completion) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            completion(nil);
                        });
                    }
                } else {
                    // Access has been denied.
                    if (completion) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            completion([NSError errorWithDomain:@"" code:PHAuthorizationStatusDenied userInfo:nil]);
                        });
                    }
                }
            }];
        } else if (status == PHAuthorizationStatusRestricted) {
            
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion([NSError errorWithDomain:@"" code:PHAuthorizationStatusRestricted userInfo:nil]);
                });
            }
        }
    });
}

#pragma mark - checkAssetsLibraryPermissions

- (void)checkAssetsLibraryPermissions:(void(^)(NSError *))completion {
    
    dispatch_async(_photoPermissionQueue, ^ {
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        
        if (status == PHAuthorizationStatusAuthorized) {
            
            // Access has been granted.
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion(nil);
                });
            }
        } else if (status == ALAuthorizationStatusDenied) {
            
            // Access has been denied.
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion([NSError errorWithDomain:@"" code:ALAuthorizationStatusDenied userInfo:nil]);
                });
            }
        } else if (status == ALAuthorizationStatusNotDetermined) {
            
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion(nil);
                });
            }
        } else if (status == ALAuthorizationStatusRestricted) {
            
            if (completion) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    completion([NSError errorWithDomain:@"" code:ALAuthorizationStatusRestricted userInfo:nil]);
                });
            }
        }
    });
}

#pragma mark - getMediaItemsFromAssetsLibrary

- (void)getMediaItemsFromAssetsLibrary:(void(^)(NSArray *))completion {
    
    dispatch_async(_photoPermissionQueue, ^ {
    
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup* group, BOOL* stop) {
            
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
                            
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                
                                if (completion) {
                        
                                    completion(array);
                                }
                            });
                        }
                    }];
                }];
            }
        } failureBlock:^(NSError* error) {
            
            NSLog(@"Error Description %@",[error description]);
        }];
    });
}

@end
