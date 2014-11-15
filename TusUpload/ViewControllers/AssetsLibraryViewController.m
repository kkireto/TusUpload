//
//  AssetsLibraryViewController.m
//
//  Created by Kireto on 2/3/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import "AssetsLibraryViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "ALAssetsLibraryManager.h"
#import "ALAssetObject.h"
#import "CustomALAssetImageView.h"
#import "ALAssetCollectionViewCell.h"

#import "AssetsUploadViewController.h"

@interface AssetsLibraryViewController ()

@property (nonatomic,strong) NSArray *assetsArray;
@property (nonatomic,strong) ALAssetsLibrary *assetslibrary;

@end

@implementation AssetsLibraryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:246.0/255.0 alpha:1.0];
	self.title = NSLocalizedString(@"Library", @"Library");
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _noContentView.hidden = YES;
    [_collectionView registerClass:[ALAssetCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [self setupNavbarButtons];
    [self loadAssetsFromLibrary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - load assets from library
- (void)loadAssetsFromLibrary {
    
    _assetsArray = nil;
    if (!_assetslibrary) {
        _assetslibrary = [[ALAssetsLibrary alloc] init];
    }
    [ALAssetsLibraryManager loadAssetsFromLibrary:_assetslibrary
                                  successCallback:^(NSArray *assetsArray) {
                                      
                                      _assetsArray = assetsArray;
                                      [_collectionView reloadData];
                                      
                                  } errorCallback:^(NSString *errorMessage) {
                                      
                                      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                                          message:errorMessage
                                                                                         delegate:nil
                                                                                cancelButtonTitle:@"Ok"
                                                                                otherButtonTitles:nil];
                                      [alertView show];
                                  }];
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_assetsArray) {
        return [_assetsArray count];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ALAssetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    ALAssetObject *alAsset = [_assetsArray objectAtIndex:indexPath.row];
    [cell.customALAssetImageView customizeViewForAsset:alAsset];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(90.0, 100.0);
    }
    return CGSizeMake(80.0, 90.0);
}

#pragma mark - setup view
- (void)setupNavbarButtons {
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBtnSelected:)];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnSelected:)];
    
    self.navigationItem.leftBarButtonItem = cancelItem;
    self.navigationItem.rightBarButtonItem = doneItem;
    
    cancelItem = nil;
    doneItem = nil;
}

#pragma mark - button selectors
- (void)cancelBtnSelected:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneBtnSelected:(id)sender {
    
    NSMutableArray *selectedAssets = [[NSMutableArray alloc] init];
    for (ALAssetObject *assetObject in _assetsArray) {
        if (assetObject.isSelected) {
            [selectedAssets addObject:assetObject.asset];
        }
    }
    if ([selectedAssets count]) {
        
        AssetsUploadViewController *controller = [[AssetsUploadViewController alloc] initWithALAssets:selectedAssets];
//        controller.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:navController animated:YES completion:nil];
        }
        else {
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"No assets selected" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - AssetsUploadProtocol
- (void)assetsUploadFinished {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Upload successfully finished" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alertView show];
    
//    [_delegate assetsUploaded];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)assetsUploadCancelled {
    
//    [_delegate assetsUploaded];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
