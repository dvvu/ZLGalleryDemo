//
//  GalleryCollectionViewCell.m
//  ZLGalleryDemo
//
//  Created by Doan Van Vu on 10/4/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GalleryCollectionViewCell.h"
#import "Constants.h"
#import "Masonry.h"

@interface GalleryCollectionViewCell () 

@property (nonatomic) UIImageView* playImageView;
@property (nonatomic) UILabel* videoDurationLabel;

@end

@implementation GalleryCollectionViewCell

#pragma mark - initWithFrame

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self layoutForCell];
    }
    
    return self;
}

#pragma mark - setModel

- (void)setModel:(id<GalleryCollectionViewCellObjectProtocol>)model {
    
    _model = model;
    
    if (_model.mediaType == MediaVideoType) {
        
        [_playImageView setHidden:NO];
        [_videoDurationLabel setHidden:NO];
        _videoDurationLabel.text = [self timeFormatted:model.videoDuration];
    } else {
        
        [_playImageView setHidden:YES];
        [_videoDurationLabel setHidden:YES];
    }
}

#pragma mark - layoutForCell

- (void)layoutForCell {
    
    CGFloat scale = FONTSIZE_SCALE;
    
    _galaryImageView = [[UIImageView alloc] init];
    [self addSubview:_galaryImageView];
    
    _playImageView = [[UIImageView alloc] init];
    _playImageView.image = [UIImage imageNamed:@"ic_play"];
    [self addSubview:_playImageView];
    
    _videoDurationLabel = [[UILabel alloc] init];
    [_videoDurationLabel setTextColor:[UIColor whiteColor]];
    [_videoDurationLabel setFont:[UIFont boldSystemFontOfSize:10 * scale]];
    [self addSubview:_videoDurationLabel];
    
    [_galaryImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.edges.equalTo(self).offset(0);
    }];
    
    [_playImageView mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.center.equalTo(self);
        make.width.and.height.mas_equalTo(self.frame.size.width/3);
    }];
    
    [_videoDurationLabel mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.bottom.equalTo(self).offset(-5);
        make.right.equalTo(self).offset(-8);
    }];
}

#pragma mark - timeFormatted

- (NSString *)timeFormatted:(int)totalSeconds {
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    if (hours) {
        
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    } else {
        
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
}

@end
