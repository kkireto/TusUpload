//
//  ALAssetObject.h
//  TheLoopUniversal
//
//  Created by Kireto on 2/3/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/ALAsset.h>

@interface ALAssetObject : NSObject

@property (nonatomic,strong) ALAsset *asset;
@property (nonatomic,strong) NSString *duration;
@property (nonatomic,assign) BOOL isSelected;

- (id)initWithALAsset:(ALAsset*)asset;

@end
