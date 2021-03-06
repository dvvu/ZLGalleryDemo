//
//  GalaryViewController.m
//  GalaryDemo
//
//  Created by Doan Van Vu on 9/30/17.
//  Copyright © 2017 Doan Van Vu. All rights reserved.
//

#import "GalleryCollectionViewDataSource.h"
#import "GalleryViewController.h"
#import "ImageSupporter.h"
#import "MediaLoader.h"
#import "MediaItem.h"
#import "Constants.h"
#import "Masonry.h"

@interface GalleryViewController () <UIAlertViewDelegate>

@property (nonatomic) GalleryCollectionViewDataSource* galleryCollectionViewDataSource;
@property (nonatomic) UICollectionView* galleryCollectionView;
@property (nonatomic) UICollectionViewFlowLayout* layout;
@property (nonatomic) UIActivityIndicatorView* activity;
@end

@implementation GalleryViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupCollectionView];
    [[ImageSupporter sharedInstance] removeAllFromFolder];
}

#pragma mark - viewWillAppear

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - viewWillDisappear

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([[UIDevice currentDevice] isGeneratingDeviceOrientationNotifications]) {
        
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
}

#pragma mark - setupCollectionView

- (void)setupCollectionView {
    
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.minimumInteritemSpacing = 3;
    _layout.minimumLineSpacing = 3;
    _layout.itemSize = CGSizeMake((self.view.bounds.size.width-12)/3, (self.view.bounds.size.width-12)/3);
    [_layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    _galleryCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    [_galleryCollectionView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_galleryCollectionView];
    
    [_galleryCollectionView mas_makeConstraints:^(MASConstraintMaker* make) {
    
        make.edges.equalTo(self.view).offset(0);
    }];
    
    [_galleryCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"GalaryCollectionViewCell"];
    _galleryCollectionViewDataSource = [[GalleryCollectionViewDataSource alloc] initWithCollectionView:_galleryCollectionView];
   
    _activity = [[UIActivityIndicatorView alloc] init];
    [_activity setBackgroundColor:[UIColor clearColor]];
    [_activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:_activity];
    
    [_activity mas_makeConstraints:^(MASConstraintMaker* make) {
        
        make.center.equalTo(self.view);
        make.width.and.height.equalTo(@40);
    }];
    
    [_activity startAnimating];
    
    MediaAuthStatus status = [[MediaLoader sharedInstance] checkPermission];
 
    if (status == MediaAuthStatusAuthorized) {
        
        [self getMediaItems];
    } else if( status == MediaAuthStatusNotDetermined) {
        
        [[MediaLoader sharedInstance] requestAuthCallbackQueue:dispatch_get_main_queue() completion:^(BOOL granted, MediaAuthStatus mediaStatus) {
            
            if (granted) {
                
                [self getMediaItems];
            } else {
                
                [self showMessage:@"Please! Enable to use" withTitle:@""];
                [_activity stopAnimating];
                [_activity removeFromSuperview];
            }
        }];
    } else {
        
        [self showMessage:@"Please! Enable to use" withTitle:@""];
        [_activity stopAnimating];
        [_activity removeFromSuperview];
    }
}

#pragma mark - getMediaItems

- (void)getMediaItems {
    
    [[MediaLoader sharedInstance] getMediaItemsCallbackQueue:dispatch_get_main_queue() completion:^(NSArray* mediaItems, NSError* error) {
        
        [_galleryCollectionViewDataSource setupData:mediaItems];
        [_activity stopAnimating];
        [_activity removeFromSuperview];
    }];
}

#pragma mark - deviceDidRotate

- (void)deviceDidRotate:(NSNotification *)notification {

    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
    // Ignore changes in device orientation if unknown, face up, or face down.
    if (!UIDeviceOrientationIsValidInterfaceOrientation(currentOrientation)) {
      
        return;
    }
    _layout.itemSize = CGSizeMake((self.view.bounds.size.width-12)/3, (self.view.bounds.size.width-12)/3);
    [_galleryCollectionView setCollectionViewLayout:_layout];
    
    NSLog(@"%f", self.view.bounds.size.width);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // goto setting
    if (buttonIndex == 1) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - showMessage

- (void)showMessage:(NSString *)message withTitle:(NSString *)title {
    
    if ([UIAlertController class]) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* settingButton = [UIAlertAction actionWithTitle:@"GO TO SETTING" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        
        UIAlertAction* closeButton = [UIAlertAction actionWithTitle:@"CLOSE" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:settingButton];
        [alert addAction:closeButton];
        
        UIViewController* viewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [viewController presentViewController:alert animated:YES completion:nil];
    } else {
        
        [[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"CLOSE" otherButtonTitles:@"GO TO SETTING", nil] show];
    }
}

@end
