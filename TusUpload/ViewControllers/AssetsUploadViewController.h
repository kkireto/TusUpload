//
//  AssetsUploadViewController.h
//
//  Created by Kireto on 2/3/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "KSTUSResumableUploadProtocol.h"
@class CustomALAssetImageView;

@interface AssetsUploadViewController : UIViewController <UIAlertViewDelegate, KSTUSResumableUploadProtocol>

//@property (nonatomic,weak) id<AssetsUploadProtocol>delegate;
@property (nonatomic,strong) IBOutlet CustomALAssetImageView *uploadThumbnail;
@property (nonatomic,strong) IBOutlet UILabel *uploadProgress;

- (id)initWithALAssets:(NSMutableArray*)assetsArray;

@end
