//
//  ImageCacher.m
//  GalaryDemo
//
//  Created by Doan Van Vu on 10/3/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ThreadSafeForMutableArray.h"
#import "ImageCacher.h"
#import "Constants.h"

@interface ImageCacher ()

@property (nonatomic) ThreadSafeForMutableArray* keyList;
@property (nonatomic) NSMutableDictionary* contactCache;
@property (nonatomic) dispatch_queue_t cacheImageQueue;
@property (nonatomic) NSUInteger maxCacheSize;
@property (nonatomic) NSUInteger totalPixel;

@end

@implementation ImageCacher

#pragma mark - singleton

+ (instancetype)sharedInstance {
    
    static ImageCacher* sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        sharedInstance = [[ImageCacher alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - intit

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _maxCacheSize = MAX_CACHE_SIZE;
        _keyList = [[ThreadSafeForMutableArray alloc] init];
        _contactCache = [[NSMutableDictionary alloc] init];
        _cacheImageQueue = dispatch_queue_create("CACHE_IMAGE_QUEUE", DISPATCH_QUEUE_SERIAL);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    
    return self;
}

#pragma mark - save to cache with image

- (void)setImageForKey:(UIImage *)image forKey:(NSString *)key {
    
    dispatch_async(_cacheImageQueue, ^ {
        
        if (image && key) {
            
            [self removeImageForKey:key completionWith:^ {
                
                // Add key into keyList
                [_keyList addObject:key];
                
                // Get size of image
                CGFloat pixelImage = [self imageSize:image];
                
                // size of image < valid memory?
                if (pixelImage <= MAX_ITEM_SIZE) {
                    
                    int index = 0;
                    while (_totalPixel > _maxCacheSize - pixelImage) {
                        
                        CGFloat size =  [self imageSize:[_contactCache objectForKey:[_keyList objectAtIndex:index]]];
                        [_contactCache removeObjectForKey:[_keyList objectAtIndex:index]];
                        _totalPixel -= size;
                        index++;
                    }
                    
                    [_contactCache setObject:image forKey:key];
                    
                    // Add size to check condition
                    _totalPixel += pixelImage;
                    NSLog(@"%lu",(unsigned long)_totalPixel);
                }
            }];
        }
    });
}

#pragma mark - get to image from cache or dir

- (void)getImageForKey:(NSString *)key completionWith:(void(^)(UIImage* image))completion {
    
    dispatch_async(_cacheImageQueue, ^ {
        
        if (key) {
            
            if (completion) {
                
                UIImage* image = [self getImageFromCache:key];
                
                if (image) {
                    
                    // Cache
                    completion(image);
                } else {
                    
                    completion(nil);
                }
            }
        } else {
            
            if (completion) {
                
                completion(nil);
            }
        }
    });
}

#pragma mark - removeImageForKey

- (void)removeImageForKey:(NSString *)key completionWith:(void(^)())completion {
    
    if (key) {
        
        dispatch_async(_cacheImageQueue, ^ {
            
            UIImage* image = [self getImageFromCache:key];
            
            if (image) {
                
                CGFloat pixelImage = [self imageSize:image];
                
                // Add size to check condition
                _totalPixel -= pixelImage;
                [_keyList removeObject:key];
                [_contactCache removeObjectForKey:key];
            }
            
            if (completion) {
                
                completion();
            }
        });
    }
}

#pragma mark - get image size

- (CGFloat)imageSize:(UIImage *)image {
    
    return image.size.height * image.size.width * [UIScreen mainScreen].scale;
}

#pragma mark - write image into cache

- (void)writeToCache:(UIImage *)image forkey:(NSString *)key {
    
    if (image && key) {
        
        [_contactCache setObject:image forKey:key];
    }
}

#pragma mark - get image from cache

- (UIImage *)getImageFromCache:(NSString *)key {
    
    if (key) {
        
        return [_contactCache objectForKey:key];
    }
    
    return nil;
}

- (void)reduceMemory {
    
    NSLog(@"Cache Error");
    //    [_contactCache removeAllObjects];
}

@end
