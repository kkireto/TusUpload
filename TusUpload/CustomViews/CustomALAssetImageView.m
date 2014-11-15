//
//  CustomALAssetImageView.m
//  TheLoopUniversal
//
//  Created by Kireto on 2/3/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import "CustomALAssetImageView.h"
#import "ALAssetObject.h"
//#import "Globals.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation CustomALAssetImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _multipleSelection = YES;
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame multipleSelection:(BOOL)multipleSelection
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _multipleSelection = multipleSelection;
        [self setupView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
#pragma mark - setup view
- (void)setupView {
    
    self.backgroundColor = [UIColor clearColor];
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    
    _durationHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 12.0, self.frame.size.width, 12.0)];
    _durationHolderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15];
    [self addSubview:_durationHolderView];
    
    _videoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"assetCameraIcon"]];
    _videoImage.frame = CGRectMake(3.0, 3.0, 8.0, 6.0);
    _videoImage.backgroundColor = [UIColor clearColor];
    [_durationHolderView addSubview:_videoImage];
    
    _durationHolderView.hidden = YES;
    
    if (_multipleSelection) {
        _selectionImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 5.0 - 27.0, self.frame.size.height - 5.0 - 27.0, 27.0, 27.0)];
        _selectionImage.backgroundColor = [UIColor clearColor];
        _selectionImage.image = [UIImage imageNamed:@"noSelected"];
        [self addSubview:_selectionImage];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectionChanged)];
        [self addGestureRecognizer:tapGesture];
    }
}

#pragma mark - customize view
- (void)customizeViewForAsset:(ALAssetObject*)assetObject {
    
    _assetObject = assetObject;
    [self setImage:[UIImage imageWithCGImage:assetObject.asset.thumbnail]];
    self.contentMode = UIViewContentModeScaleAspectFill;
    if (_assetObject.duration && [_assetObject.duration length]) {
        _durationHolderView.hidden = NO;
    }
    else {
        _durationHolderView.hidden = YES;
    }
    if (_multipleSelection) {
        [self updateSelectionImage];
    }
}

- (void)updateSelectionImage {
    
    if (_assetObject.isSelected) {
        _selectionImage.image = [UIImage imageNamed:@"selected"];
    }
    else {
        _selectionImage.image = [UIImage imageNamed:@"noSelected"];
    }
}

- (void)selectionChanged {
    
    if (_assetObject) {
        _assetObject.isSelected = !_assetObject.isSelected;
        [self updateSelectionImage];
    }
}

#pragma mark - updateUploadProgress
- (void)updateUploadProgress:(float)progress {
    
    if (progress > 1) {
        progress = 1;
    }
    NSString *progressString = [NSString stringWithFormat:@"Uploading... %.0f%%", 100.0*progress];
    if ([progressString isEqualToString:@"Uploading... 100%"]) {
        progressString = @"Uploading... 99%";
    }
    if (!_uploadMaskLayer) {
        _uploadMaskLayer = [[CALayer alloc] init];
        [_uploadMaskLayer setFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        [_uploadMaskLayer setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.5].CGColor];
        [self.layer addSublayer:_uploadMaskLayer];
    }
    if (!_uploadProgressLabel) {
        CGRect progressLabelFrame = CGRectMake(6.0, 6.0, self.frame.size.width - 12.0, 34.0);
        UIFont *progressLabelFont = [UIFont fontWithName:@"Avenir-Roman" size:14.0];
        UIColor *progressLabelColor = [UIColor colorWithWhite:1.0 alpha:1.0];
        CGSize labelSize = [progressString sizeWithFont:progressLabelFont constrainedToSize:progressLabelFrame.size lineBreakMode:NSLineBreakByWordWrapping];
        progressLabelFrame.size.height = labelSize.height;
        _uploadProgressLabel = [self labelWithFrame:progressLabelFrame labelFont:progressLabelFont labelColor:progressLabelColor alignment:NSTextAlignmentLeft andLabelTitle:progressString];
        _uploadProgressLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:_uploadProgressLabel];
    }
    _uploadProgressLabel.text = progressString;
    if (progress == 1) {
        [_uploadMaskLayer removeFromSuperlayer];
        _uploadMaskLayer = nil;
    }
    else {
        CGFloat originX = progress * self.frame.size.width;
        [_uploadMaskLayer setFrame:CGRectMake(originX, 0.0, self.frame.size.width - originX, self.frame.size.height)];
    }
}

- (UILabel*)labelWithFrame:(CGRect)labelFrame
                 labelFont:(UIFont*)labelFont
                labelColor:(UIColor*)labelColor
                 alignment:(NSTextAlignment)textAlignment
             andLabelTitle:(NSString*)labelTitle {
    
    UILabel *returnLabel = [[UILabel alloc] initWithFrame:labelFrame];
    returnLabel.backgroundColor = [UIColor clearColor];
    returnLabel.font = labelFont;
    returnLabel.textColor = labelColor;
    returnLabel.textAlignment = textAlignment;
    returnLabel.text = labelTitle;
    return returnLabel;
}

- (UILabel*)labelWithFrame:(CGRect)labelFrame
             numberOfLines:(NSUInteger)numberOfLines
                 labelFont:(UIFont*)labelFont
                labelColor:(UIColor*)labelColor
                 alignment:(NSTextAlignment)textAlignment
             andLabelTitle:(NSString*)labelTitle {
    
    UILabel *returnLabel = [[UILabel alloc] initWithFrame:labelFrame];
    returnLabel.backgroundColor = [UIColor clearColor];
    returnLabel.font = labelFont;
    returnLabel.textColor = labelColor;
    returnLabel.textAlignment = textAlignment;
    returnLabel.numberOfLines = numberOfLines;
    returnLabel.text = labelTitle;
    return returnLabel;
}

- (UILabel*)labelWithFrame:(CGRect)labelFrame
                 labelFont:(UIFont*)labelFont
                labelColor:(UIColor*)labelColor
                 alignment:(NSTextAlignment)textAlignment
                labelTitle:(NSString*)labelTitle
               shadowColor:(UIColor*)shadowColor
              shadowOffset:(CGSize)shadowOffset {
    
    UILabel *returnLabel = [self labelWithFrame:labelFrame
                                         labelFont:labelFont
                                        labelColor:labelColor
                                         alignment:textAlignment
                                     andLabelTitle:labelTitle];
    returnLabel.shadowColor = shadowColor;
    returnLabel.shadowOffset = shadowOffset;
    return returnLabel;
}

@end
