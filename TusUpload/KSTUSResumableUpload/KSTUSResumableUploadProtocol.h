//
//  KSTUSResumableUploadProtocol.h
//  TusUpload
//
//  Created by Kireto on 7/11/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

@protocol KSTUSResumableUploadProtocol <NSObject>

- (void)uploadProgress:(float)uploadProgress;
- (void)uploadFinished;
- (void)uploadPaused;
- (void)uploadFailled;

@end