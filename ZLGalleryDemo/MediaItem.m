//
//  MediaItem.m
//  GalaryDemo
//
//  Created by Doan Van Vu on 10/2/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "UIImage+Supporter.h"
#import "ImageCacher.h"
#import "MediaItem.h"

@implementation MediaItem

#pragma mark - initWithPHAsset

- (void)initWithPHAsset:(PHAsset *)asset completion:(void(^)(MediaItem *))completion {
    
    if (asset) {
        
        _creationDate = [asset creationDate];
        _identifier = asset.localIdentifier;
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData* imageData, NSString* dataUTI, UIImageOrientation orientation, NSDictionary* info) {
                
                if ([info objectForKey:@"PHImageFileURLKey"]) {
                    
                    _inputType = AssetInput;
                    _imageUrl = [info objectForKey:@"PHImageFileURLKey"];
                    _mediaType = MediaImageType;
                    
                    UIImage* image = [UIImage imageWithData:imageData];
                    
                    if(image) {
                        
                        [[ImageCacher sharedInstance] setImageForKey:[image resizeImage:100] forKey:asset.localIdentifier];
                    }
                }
                
                if (completion) {
                    
                    completion(self);
                }
            }];
        } else {
        
            [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset* _Nullable assetVideo, AVAudioMix* _Nullable audioMix, NSDictionary* _Nullable info) {
                
                AVURLAsset* playerAsset = (AVURLAsset*)assetVideo;
                
                _inputType = AssetInput;
                _videoUrl = [playerAsset URL];
                _mediaType = MediaVideoType;
                _urlAsset = playerAsset;
                _videoDuration = ceil(playerAsset.duration.value/playerAsset.duration.timescale);
                
                if (completion) {
                    
                    completion(self);
                }
                
                UIImage* image = [self thumbnailFromVideoURL:_videoUrl atCMTime:playerAsset.duration];
           
                if (image) {
                    
                    [[ImageCacher sharedInstance] setImageForKey:[image resizeImage:100] forKey:asset.localIdentifier];
                }
            }];
        }
    } else {
        
        if (completion) {
            
            completion(nil);
        }
    }
}

#pragma mark - initWithALAssetsGroup

- (void)initWithALAsset:(ALAsset *)asset completion:(void(^)(MediaItem *))completion {
    
    if (asset) {
        
        ALAssetRepresentation* defaultRepresentation = [asset defaultRepresentation];
        NSURL* url = [defaultRepresentation url];
        
        _creationDate = [asset valueForProperty:ALAssetPropertyDate];
        _identifier = url.absoluteString;
        
        if ([asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto) {
            
            _imageUrl = url;
            _mediaType = MediaImageType;
            
            UIImage* image = [UIImage imageWithCGImage:[defaultRepresentation fullScreenImage]];
            
            if (image) {
                
                [[ImageCacher sharedInstance] setImageForKey:[image resizeImage:100] forKey:url.absoluteString];
            }
        } else {
            
            _videoUrl = url;
            _mediaType = MediaVideoType;
            _videoDuration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
            
            UIImage* image = [UIImage imageWithCGImage:[defaultRepresentation fullScreenImage]];
            
            if (image) {
                
                [[ImageCacher sharedInstance] setImageForKey:[image resizeImage:100] forKey:url.absoluteString];
            }
        }
        
        if (completion) {
            
            completion(self);
        }
    } else {
        
        if (completion) {
            
            completion(nil);
        }
    }
}

#pragma mark - initWithALAssetsGroup
// get image at time in video.

- (UIImage *)thumbnailFromVideoURL:(NSURL *)videoURL atCMTime:(CMTime)time {
    
    UIImage* image = nil;
    AVAsset* asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator* imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    // get the image from
    NSError* error = nil;
    CMTime actualTime;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    if (imageRef) {
        
        image = [[UIImage alloc] initWithCGImage:imageRef];
    }
    
    CGImageRelease(imageRef);
    
    return image;
}

@end
