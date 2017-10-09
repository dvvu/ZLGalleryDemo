//
//  MediaItem.m
//  GalaryDemo
//
//  Created by Doan Van Vu on 10/2/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "ImageSupporter.h"
#import "ImageCacher.h"
#import "MemoryCache.h"
#import "MediaItem.h"

@implementation MediaItem

#pragma mark - initWithPHAsset

- (void)initWithPHAsset:(PHAsset *)asset completion:(void(^)(MediaItem *))completion {
    
    PHAssetMediaType type = asset.mediaType;
    
    if (type == PHAssetMediaTypeImage) {
        
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData* imageData, NSString* dataUTI, UIImageOrientation orientation, NSDictionary* info) {
            
            if ([info objectForKey:@"PHImageFileURLKey"]) {
                
                _imageUrl = [info objectForKey:@"PHImageFileURLKey"];
                _creationDate = [asset creationDate];
                _identifier = [asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""];
                _mediaType = MediaImageType;
                _inputType = AssetInput;
                _isSelected = NO;
                
                if (completion) {
                    
                    completion(self);
                }
                
                UIImage* image = [UIImage imageWithData:imageData];
                [self storeImage:image withIdentifier:_identifier];
            }
        }];
    } else if (type == PHAssetMediaTypeVideo) {
        
        [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset* _Nullable assetVideo, AVAudioMix* _Nullable audioMix, NSDictionary* _Nullable info) {
            
            AVURLAsset* playerAsset = (AVURLAsset *)assetVideo;
            
            _videoDuration = ceil(playerAsset.duration.value/playerAsset.duration.timescale);
            _creationDate = [asset creationDate];
            _identifier = [asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@""];
            _inputType = AssetInput;
            _videoUrl = [playerAsset URL];
            _mediaType = MediaVideoType;
            _urlAsset = playerAsset;
            _isSelected = NO;
            
            if (completion) {
                
                completion(self);
            }
            
            UIImage* image = [self thumbnailFromVideoURL:_videoUrl atCMTime:playerAsset.duration];
            [self storeImage:image withIdentifier:_identifier];
        }];
    } else {
        
        if (completion) {
            
            completion(nil);
        }
    }
}

#pragma mark - initWithALAssetsGroup

- (void)initWithALAsset:(ALAsset *)asset completion:(void(^)(MediaItem *))completion {
    
    NSString* type = [asset valueForProperty:ALAssetPropertyType];
    
    if (type == ALAssetTypePhoto) {
        
        ALAssetRepresentation* defaultRepresentation = [asset defaultRepresentation];
        NSURL* url = [defaultRepresentation url];
        _creationDate = [asset valueForProperty:ALAssetPropertyDate];
        _identifier = [url.absoluteString stringByReplacingOccurrencesOfString:@"/" withString:@""];
        _mediaType = MediaImageType;
        _imageUrl = url;
        _isSelected = NO;
        
        if (completion) {
            
            completion(self);
        }
        
        UIImage* image = [UIImage imageWithCGImage:[defaultRepresentation fullScreenImage]];
        [self storeImage:image withIdentifier:_identifier];
    } else if (type == ALAssetTypeVideo) {
        
        ALAssetRepresentation* defaultRepresentation = [asset defaultRepresentation];
        NSURL* url = [defaultRepresentation url];
        _videoDuration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        _creationDate = [asset valueForProperty:ALAssetPropertyDate];
        _identifier = [url.absoluteString stringByReplacingOccurrencesOfString:@"/" withString:@""];
        _mediaType = MediaVideoType;
        _videoUrl = url;
        _isSelected = NO;
        
        if (completion) {
            
            completion(self);
        }
        
        UIImage* image = [UIImage imageWithCGImage:[defaultRepresentation fullScreenImage]];
        [self storeImage:image withIdentifier:_identifier];
    } else {
        
        if (completion) {
            
            completion(nil);
        }
    }
}

#pragma mark - storeImage

- (void)storeImage:(UIImage *)image withIdentifier:(NSString *)identifier {
    
    if (image) {
        
        image = [[ImageSupporter sharedInstance] resizeImageToFit:image];
        [[ImageSupporter sharedInstance] storeImageToFolder:image withImageName:identifier];
        [[ContactImageMemoryCache sharedInstance] addObject:image name:identifier];
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
    image = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

@end
