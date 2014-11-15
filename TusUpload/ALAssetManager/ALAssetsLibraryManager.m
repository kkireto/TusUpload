/*
 * Copyright 2013 Kreto. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation and/or
 *    other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY Kireto “AS IS” WITHOUT ANY WARRANTIES WHATSOEVER.
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF NON INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL Kireto OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * The views and conclusions contained in the software and documentation are those of
 * the authors and should not be interpreted as representing official policies,
 * either expressed or implied, of Kireto.
*/

#import "ALAssetsLibraryManager.h"
#import "ALAssetObject.h"

@implementation ALAssetsLibraryManager

+ (void)loadAssetsFromLibrary:(ALAssetsLibrary*)assetsLibrary
              successCallback:(void (^)(NSArray *assetsArray)) successCallback
                errorCallback:(void (^)(NSString *errorMessage)) errorCallback {
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted) {
        errorCallback(NSLocalizedString(@"Access to your photo library is disabled for this application, please enable them from the Privacy tab in Settings.", @""));
    }
    else {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
        if (!assetsLibrary) {
            assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                    if (asset){
                        ALAssetObject *assetObject = [[ALAssetObject alloc] initWithALAsset:asset];
                        [tmpArray insertObject:assetObject atIndex:0];
                        assetObject = nil;
                    }
                }];
            }
            else {
                successCallback([ALAssetsLibraryManager sortedAssets:tmpArray byDate:@"date"]);
            }
        } failureBlock:^(NSError *error) {
            errorCallback(error.localizedDescription);
        }];
    }
}

+ (void)checkAccessToAssetsFromLibrary:(ALAssetsLibrary*)assetsLibrary
                       successCallback:(void (^)(NSString *successMessage)) successCallback
                         errorCallback:(void (^)(NSString *errorMessage)) errorCallback {
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusDenied || status == ALAuthorizationStatusRestricted) {
        errorCallback(NSLocalizedString(@"Access to your photo library is disabled for this application, please enable them from the Privacy tab in Settings.", @""));
    }
    else {
        if (!assetsLibrary) {
            assetsLibrary = [[ALAssetsLibrary alloc] init];
        }
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (group) {
                NSLog(@"numberOfAssets:%i", (int)[group numberOfAssets]);
            }
            else {
                successCallback(@"successCallback");
            }
            
        } failureBlock:^(NSError *error) {
            
            errorCallback(error.localizedDescription);
        }];
    }
}

+ (NSArray*)sortedAssets:(NSArray*)assetList byDate:(NSString*)dateParamString {
    NSSortDescriptor* sortByDate = [NSSortDescriptor sortDescriptorWithKey:dateParamString ascending:NO];
    NSArray *sortedArray = [assetList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByDate]];
    return sortedArray;
}

+ (ALAssetOrientation)getALAssetFromImageOrientation:(UIImageOrientation)imageOrientation {
    
    ALAssetOrientation retValue = ALAssetOrientationUp;
    switch (imageOrientation) {
        case UIImageOrientationUp:
            retValue = ALAssetOrientationUp;
            break;
        case UIImageOrientationDown:
            retValue = ALAssetOrientationDown;
            break;
        case UIImageOrientationLeft:
            retValue = ALAssetOrientationLeft;
            break;
        case UIImageOrientationRight:
            retValue = ALAssetOrientationRight;
            break;
        case UIImageOrientationUpMirrored:
            retValue = ALAssetOrientationUpMirrored;
            break;
        case UIImageOrientationDownMirrored:
            retValue = ALAssetOrientationDownMirrored;
            break;
        case UIImageOrientationLeftMirrored:
            retValue = ALAssetOrientationLeftMirrored;
            break;
        case UIImageOrientationRightMirrored:
            retValue = ALAssetOrientationRightMirrored;
            break;
        default:
            break;
    }
    return retValue;
}

@end
