//
//  AssetsLibraryViewController.h
//  
//
//  Created by Kireto on 2/3/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Protocols.h"

@interface AssetsLibraryViewController : UIViewController //<AssetsUploadProtocol>

//@property (nonatomic,weak) id<AssetsLibraryProtocol>delegate;
@property (nonatomic,strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) IBOutlet UIImageView *noContentView;

@end
