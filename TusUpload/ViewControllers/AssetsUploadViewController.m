//
//  AssetsUploadViewController.m
//
//  Created by Kireto on 2/3/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import "AssetsUploadViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "KSTUSResumableUpload.h"
#import "CustomALAssetImageView.h"
#import "ALAssetObject.h"

#define CANCEL_ALERT_TAG 10101014

@interface AssetsUploadViewController ()

@property (nonatomic,strong) ALAsset *uploadingAsset;
@property (nonatomic,strong) UIAlertView *cancelAllert;
@property (nonatomic,strong) NSMutableArray *assetsArray;
@property (nonatomic,assign) BOOL uploadCancelled;
@property (nonatomic,assign) BOOL viewDidAppear;
@property (nonatomic,assign) BOOL shouldDismissView;
@property (nonatomic,assign) NSUInteger assetsForUpload;
@property (nonatomic,assign) NSUInteger assetsIndex;
@property (nonatomic,strong) KSTUSResumableUpload *ksTusUpload;

@end

@implementation AssetsUploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithALAssets:(NSMutableArray*)assetsArray
{
    self = [super init];
    if (self) {
        // Custom initialization
        _assetsArray = assetsArray;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
	self.title = NSLocalizedString(@"Uploading...", @"Uploading...");
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnSelected:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    cancelItem = nil;
    
    _assetsIndex = 0;
    _assetsForUpload = [_assetsArray count];
    _uploadCancelled = NO;
    _viewDidAppear = NO;
    _shouldDismissView = NO;
    
    _uploadThumbnail.layer.cornerRadius = 4.0;
    [_uploadThumbnail.layer setMasksToBounds:YES];
    
    [self uploadAssetsAction];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _viewDidAppear = YES;
    if (_shouldDismissView) {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)uploadAssetsAction {
    
    if (_uploadCancelled) {
        [_assetsArray removeAllObjects];
    }
    if ([_assetsArray count]) {
        _assetsIndex++;
        ALAsset *asset = [_assetsArray objectAtIndex:0];
        [self uploadAssets:asset];
    }
    else {
        [self assetUploadedFinished];
    }
}

- (void)uploadAssets:(ALAsset*)asset {
    
    _uploadProgress.text = [NSString stringWithFormat:@"Uploading %i of %i", (int)_assetsIndex, (int)_assetsForUpload];
    ALAssetObject *assetObject = [[ALAssetObject alloc] initWithALAsset:asset];
    [_uploadThumbnail customizeViewForAsset:assetObject];
    
    if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypePhoto"]) {
        
    }
    else if ([[asset valueForProperty:@"ALAssetPropertyType"] isEqualToString:@"ALAssetTypeVideo"]) {
        [self uploadDataFromAsset:asset];
    }
}

- (void)assetUploaded:(ALAsset*)asset {
    
    [_assetsArray removeObject:asset];
    [self uploadAssetsAction];
}

- (void)assetUploadedFinished {
    if (_cancelAllert) {
        [_cancelAllert dismissWithClickedButtonIndex:_cancelAllert.cancelButtonIndex animated:NO];
    }
    if (_viewDidAppear) {
        [self dismissViewControllerAnimated:YES completion:^{
//            [_delegate assetsUploadFinished];
        }];
    }
    else {
        _shouldDismissView = YES;
//        [_delegate assetsUploadFinished];
    }
}

- (void)assetUploadedFailled {
    if (_cancelAllert) {
        [_cancelAllert dismissWithClickedButtonIndex:_cancelAllert.cancelButtonIndex animated:NO];
    }
    if (_viewDidAppear) {
        [self dismissViewControllerAnimated:YES completion:^{
//            [_delegate assetsUploadCancelled];
        }];
    }
    else {
        _shouldDismissView = YES;
//        [_delegate assetsUploadCancelled];
    }
}

#pragma mark - button selectors
- (void)cancelBtnSelected:(id)sender {
    
    if (!_cancelAllert) {
        _cancelAllert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to cancel the upload" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        _cancelAllert.tag = CANCEL_ALERT_TAG;
        [_cancelAllert show];
    }
}

- (void)cancelUploadAction {
    
    _uploadCancelled = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self dismissViewControllerAnimated:YES completion:^{
        [_ksTusUpload cancelUpload];
//        [_delegate assetsUploadCancelled];
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == CANCEL_ALERT_TAG) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            
        }
        else {
            [self cancelUploadAction];
        }
    }
}

- (void)resumeUploadDataFromAsset:(ALAsset*)asset
{
    
}

- (void)uploadDataFromAsset:(ALAsset*)asset
{
    _ksTusUpload = nil;
    _uploadingAsset = asset;
    _ksTusUpload = [[KSTUSResumableUpload alloc] initForALAsset:asset andDelegate:self];
    _ksTusUpload.delegate = self;
}

#pragma mark - KSTUSResumableUploadProtocol
- (void)uploadProgress:(float)uploadProgress {
    [_uploadThumbnail updateUploadProgress:uploadProgress];
}

- (void)uploadFinished {
    [self assetUploadedFinished];
}

- (void)uploadPaused {
    [self assetUploadedFailled];
}

- (void)uploadFailled {
    [self assetUploadedFailled];
}

@end
