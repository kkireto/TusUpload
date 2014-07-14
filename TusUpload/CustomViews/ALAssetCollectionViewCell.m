//
//  ALAssetCollectionViewCell.m
//  TheLoopUniversal
//
//  Created by Kireto on 2/27/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import "ALAssetCollectionViewCell.h"
#import "CustomALAssetImageView.h"

#define al_asset_image_width 75.0
#define al_asset_image_height 75.0

@implementation ALAssetCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        if (!_customALAssetImageView) {
            _customALAssetImageView = [[CustomALAssetImageView alloc] initWithFrame:CGRectMake((self.contentView.frame.size.width - al_asset_image_width)/2, (self.contentView.frame.size.height - al_asset_image_height)/2, al_asset_image_width, al_asset_image_height) multipleSelection:YES];
            [self.contentView addSubview:_customALAssetImageView];
        }
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

@end
