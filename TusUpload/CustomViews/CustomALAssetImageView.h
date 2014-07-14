//
//  CustomALAssetImageView.h
//  TheLoopUniversal
//
//  Created by Kireto on 2/3/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ALAssetObject;

@interface CustomALAssetImageView : UIImageView

@property (nonatomic,strong) ALAssetObject *assetObject;
@property (nonatomic,strong) UIImageView *selectionImage;
@property (nonatomic,strong) UILabel *uploadProgressLabel;
@property (nonatomic,strong) UIView *durationHolderView;
@property (nonatomic,strong) UIImageView *videoImage;
@property (nonatomic,strong) CALayer *uploadMaskLayer;
@property (nonatomic,assign) BOOL multipleSelection;

- (id)initWithFrame:(CGRect)frame multipleSelection:(BOOL)multipleSelection;

- (void)customizeViewForAsset:(ALAssetObject*)assetObject;
- (void)updateUploadProgress:(float)progress;

@end
