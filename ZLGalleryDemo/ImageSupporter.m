//
//  ImageSupporter.m
//  ZLGalleryDemo
//
//  Created by Doan Van Vu on 10/6/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ImageSupporter.h"
#import "Constants.h"

@interface ImageSupporter ()

@property (nonatomic) dispatch_queue_t ImageSupporterQueue;

@end

@implementation ImageSupporter

#pragma mark - singleton

+ (instancetype)sharedInstance {
    
    static ImageSupporter* sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^ {
        
        sharedInstance = [[ImageSupporter alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - init

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        _ImageSupporterQueue = dispatch_queue_create("IMAGE_SUPPORTER_QUEUE", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - getImageFromFoder

- (void)getImageFromFolder:(NSString *)imageName completion:(void(^)(UIImage* image))compeltion {
    
    dispatch_async(_ImageSupporterQueue, ^ {
        
        //Get image file from sand box using file name and file path
        NSString* stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingPathComponent:@"ImageFolder"];
        stringPath = [stringPath stringByAppendingPathComponent:imageName];
        
        UIImage* image = [UIImage imageWithContentsOfFile:stringPath];
        
        if (compeltion) {
            
            if (image) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    compeltion(image);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    compeltion(nil);
                });
            }
        }
    });
}

#pragma mark - storeImageToDirectory

- (void)storeImageToFolder:(UIImage *)image withImageName:(NSString *)imageName {
    
    dispatch_barrier_async(_ImageSupporterQueue, ^ {
        
        // For error information
        NSError* error;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* dataPath = [documentsDirectory stringByAppendingPathComponent:@"ImageFolder"];
        
        if (![fileManager fileExistsAtPath:dataPath]) {
            
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
        }
        
        NSData* imageData = UIImagePNGRepresentation(image);
        
        NSString* imgfileName = [NSString stringWithFormat:@"%@%@", imageName, @".png"];
        
        // File is created in the documents directory
        NSString* imgfilePath = [dataPath stringByAppendingPathComponent:imgfileName];
        
        // Write the file
        [imageData writeToFile:imgfilePath atomically:YES];
    });
}

#pragma mark - removeImageFromFolder

- (void)removeImageFromFolder:(NSString *)imageName {
    
    dispatch_barrier_async(_ImageSupporterQueue, ^ {
        
        // For error information
        NSError* error;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* dataPath = [documentsDirectory stringByAppendingPathComponent:@"ImageFolder"];
        
        NSString* imagwNamePath = [NSString stringWithFormat:@"%@/%@%@", dataPath, imageName, @".png"];
        
        if ([fileManager fileExistsAtPath:dataPath]) {
            
            [fileManager removeItemAtPath:imagwNamePath error:&error];
        }
    });
}

#pragma mark - removeAllFromFolder

- (void)removeAllFromFolder {
    
    dispatch_barrier_async(_ImageSupporterQueue, ^ {
        
        // For error information
        NSError* error;
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* dataPath = [documentsDirectory stringByAppendingPathComponent:@"ImageFolder"];
        
        if ([fileManager fileExistsAtPath:dataPath]) {
            
            [fileManager removeItemAtPath:dataPath error:&error];
        }
    });
}

#pragma mark - resizeImage

- (void)resizeImageToFit:(UIImage *)image completion:(void(^)(UIImage *))completion {
    
    dispatch_async(_ImageSupporterQueue, ^{
        
        CGAffineTransform scaleTransform;
        UIImage* imageResult = nil;
        CGPoint origin;
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        
        if (imageWidth > imageHeight) {
            
            CGFloat scaleRatio = IMAGE_SIZE / imageHeight;
            scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
            origin = CGPointMake(-(imageWidth - imageHeight) / 2, 0);
        } else {
            
            CGFloat scaleRatio = IMAGE_SIZE / imageWidth;
            scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
            origin = CGPointMake(0, -(imageHeight - imageWidth) / 2);
        }
        
        CGSize size = CGSizeMake(IMAGE_SIZE, IMAGE_SIZE);
        
        // Begin ImageContext
        UIGraphicsBeginImageContext(size);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextConcatCTM(context, scaleTransform);
        [image drawAtPoint:origin];
        
        imageResult = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (completion) {
                
                completion(imageResult);
            }
        });
    });
}

#pragma mark - resizeImage

- (UIImage *)resizeImageToFit:(UIImage *)image {
 
    CGAffineTransform scaleTransform;
    UIImage* imageResult = nil;
    CGPoint origin;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    if (imageWidth > imageHeight) {
        
        CGFloat scaleRatio = IMAGE_SIZE / imageHeight;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(-(imageWidth - imageHeight) / 2, 0);
    } else {
        
        CGFloat scaleRatio = IMAGE_SIZE / imageWidth;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        origin = CGPointMake(0, -(imageHeight - imageWidth) / 2);
    }
    
    CGSize size = CGSizeMake(IMAGE_SIZE, IMAGE_SIZE);
    
    // Begin ImageContext
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    [image drawAtPoint:origin];
    
    imageResult = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageResult;
}

@end
