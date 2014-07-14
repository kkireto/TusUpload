//
//  KSTUSResumableUpload.h
//  TusUpload
//
//  Created by Kireto on 7/11/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "KSTUSResumableUploadProtocol.h"

@interface KSTUSResumableUpload : NSObject

@property (nonatomic,weak) id<KSTUSResumableUploadProtocol>delegate;

- (id)initForALAsset:(ALAsset *)asset
         andDelegate:(id<KSTUSResumableUploadProtocol>)delegate;
- (id)initForALAssetWithURL:(NSURL*)assetURL
                   withName:(NSString*)assetName
                andDelegate:(id<KSTUSResumableUploadProtocol>)delegate;
- (void)cancelUpload;

@end
