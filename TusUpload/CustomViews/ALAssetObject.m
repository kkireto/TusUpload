//
//  ALAssetObject.m
//  TheLoopUniversal
//
//  Created by Kireto on 2/3/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import "ALAssetObject.h"

@implementation ALAssetObject

- (id)initWithALAsset:(ALAsset*)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        _isSelected = NO;
        if ([_asset valueForProperty:ALAssetPropertyDuration] != ALErrorInvalidProperty) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"mm:ss"];
            _duration = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[[_asset valueForProperty:ALAssetPropertyDuration] doubleValue]]];
            formatter = nil;
        }
        else {
            _duration = @"";
        }
    }
    return self;
}

@end
