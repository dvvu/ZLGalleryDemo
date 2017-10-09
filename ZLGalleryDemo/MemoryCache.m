//
//  MemoryCache.m
//  Cache
//
//  Created by Mihozil on 9/22/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import "MemoryCache.h"

@interface MemoryCache()

@property (nonatomic) NSMutableDictionary* cacheMap;
@property (nonatomic) NSMutableOrderedSet* lruCacheObjects;
@property (nonatomic) dispatch_queue_t memoryCacheQueue;

@end

double const numberOfBytesPerPixel = 3.0;
double const cacheMemoryPercentage = 0.10;

@implementation MemoryCache

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        _cacheMap = [[NSMutableDictionary alloc] init];
        _lruCacheObjects = [[NSMutableOrderedSet alloc] init];
    }
    
    return self;
}

- (MemoryCacheInfo *)cacheInfoForName:(NSString *)name {
    
    @synchronized (self) {
        
        return _cacheMap[name];
    }
}

- (void)removeCacheInfoForName:(NSString *)name {
    
    @synchronized (self) {
        
        MemoryCacheInfo* memoryCacheInfo = [self cacheInfoForName:name];
       
        if (!memoryCacheInfo) {
            
            return;
        }
        
        [self willRemoveObject:memoryCacheInfo.object forKey:memoryCacheInfo.name];
        
        [_lruCacheObjects removeObject:memoryCacheInfo];
        [_cacheMap removeObjectForKey:memoryCacheInfo.name];
    }
}

#pragma mark subclasses

- (void)addObject:(id)object name:(NSString *)name {
    
    @synchronized (self) {
        
        MemoryCacheInfo* memoryCacheInfo = [self cacheInfoForName:name];
        
        if (!memoryCacheInfo) {
            
            memoryCacheInfo = [[MemoryCacheInfo alloc] initWithName:name object:object];
        }
        
        [_cacheMap setObject:memoryCacheInfo forKey:name];
        [_lruCacheObjects addObject:memoryCacheInfo];
    }
}

- (id)objectForKey:(NSString *)name {
    
    @synchronized (self) {
        
        MemoryCacheInfo* memoryCacheInfo = [self cacheInfoForName:name];
        
        if (!memoryCacheInfo) {
            
            return nil;
        }
        
        [_lruCacheObjects removeObject:memoryCacheInfo];
        [_lruCacheObjects addObject:memoryCacheInfo];
        
        return memoryCacheInfo.object;
    }
}

- (void)removeObjectForKey:(NSString *)name {
    
    @synchronized (self) {
        
        [self removeCacheInfoForName:name];
    }
}

- (void)removeAllObjects {
    
    @synchronized (self) {
        
        [_lruCacheObjects removeAllObjects];
        [_cacheMap removeAllObjects];
    }
}

- (void)willRemoveObject:(id)object forKey:(NSString *)key {
    
}

- (BOOL)shouldSetObject:(id)object forKey:(NSString *)name {
    
    return YES;
}

- (void) didSetObject:(id)object forKey:(NSString*)name {
    
}

@end

@implementation MemoryCacheInfo

- (instancetype)initWithName:(NSString*)name object:(id)object {
    
    self = [super init];
    
    if (self) {
        
        _name = name;
        _object = object;
    }
    
    return self;
}

@end

@implementation ContactImageMemoryCache

+ (instancetype)sharedInstance {
    
    static ContactImageMemoryCache* memoryCache = nil;
    static dispatch_once_t onceToken;
  
    dispatch_once(&onceToken, ^{
    
        memoryCache = [[ContactImageMemoryCache alloc] init];
    });
    
    return memoryCache;
}

- (id)init {
    
    self = [super init];
 
    if (self) {
     
        _maxNumberOfPixel = 2*1024*1024;//[NSProcessInfo processInfo].physicalMemory * cacheMemoryPercentage / numberOfBytesPerPixel; // get 1% of physicalMemory to save image
    }
    
    return self;
}

- (void)insertInfoToLruCache:(MemoryCacheInfo*)info forName:(NSString *)name {
    
    @synchronized (self) {
        
        id previousObject = [[self cacheInfoForName:name] object];
        
        if ([self shouldSetObject:info.object forKey:name previousObject:previousObject]) {
            
            [self.lruCacheObjects removeObject:info];
            [self.lruCacheObjects addObject:info];
            [self.cacheMap setObject:info forKey:name];
            
            [self didSetObject:info.object forKey:info.name];
        }
        
        NSLog(@"%f", _numberOfPixel);
    }
}

- (void)addObject:(id)object name:(NSString *)name {
    
    @synchronized (self) {
        
        MemoryCacheInfo* memoryCacheInfo = [self cacheInfoForName:name];
       
        if (!memoryCacheInfo) {
            
            memoryCacheInfo = [[MemoryCacheInfo alloc] initWithName:name object:object];
        }
        
        [self insertInfoToLruCache:memoryCacheInfo forName:name];
    }
}

- (void)didSetObject:(id)object forKey:(NSString *)name {
    
    @synchronized (self) {
        
        while (_numberOfPixel > _maxNumberOfPixel) {
            
            MemoryCacheInfo* memoryCacheInfo = [self.lruCacheObjects firstObject];
            [self removeObjectForKey:memoryCacheInfo.name];
        }
    }
}

- (BOOL)shouldSetObject:(id)object forKey:(NSString *)name previousObject:(id)previousObject{
  
    @synchronized (self) {
        
        if (![object isKindOfClass:[UIImage class]]) {
        
            return NO;
        }
        
        _numberOfPixel -= [self numberOfPixelByImage:previousObject];
        _numberOfPixel += [self numberOfPixelByImage:object];
        return true;
    }
}

- (void)willRemoveObject:(id)object forKey:(NSString *)key {
    
    @synchronized (self) {
        
        _numberOfPixel -= [self numberOfPixelByImage:object];
    }
}

- (void)removeAllObjects {
    
    @synchronized (self) {
        
        _numberOfPixel = 0;
        
        [self.lruCacheObjects removeAllObjects];
        [self.cacheMap removeAllObjects];
    }
}

- (double)numberOfPixelByImage:(UIImage *)image {
    
    @synchronized (self) {
        
        if (!image) {
            
            return 0;
        }
        
        return image.size.width * image.size.height * image.scale * image.scale;
    }
}

@end


