//
//  MemoryCache.h
//  Cache
//
//  Created by Mihozil on 9/22/17.
//  Copyright © 2017 Mihozil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MemoryCache : NSObject

- (void)addObject:(id)object name:(NSString *)name;
- (id)objectForKey:(NSString *)name;
- (void)removeObjectForKey:(NSString*)name;
- (void)removeAllObjects;

- (BOOL)shouldSetObject:(id)object forKey:(NSString *)name;
- (void)didSetObject:(id)object forKey:(NSString *)name;
- (void)willRemoveObject:(id)object forKey:(NSString *)key;

@end


@interface MemoryCacheInfo : NSObject

@property (nonatomic) id object;
@property (nonatomic) NSString* name;
- (instancetype)initWithName:(NSString *)name object:(id)object;

@end


@interface ContactImageMemoryCache : MemoryCache

+ (instancetype)sharedInstance;

@property (assign, nonatomic) double numberOfPixel;
@property (assign, nonatomic) double maxNumberOfPixel;

@end
