//
//  KSTUSResumableUpload.m
//  TusUpload
//
//  Created by Kireto on 7/11/14.
//  Copyright (c) 2014 No Name. All rights reserved.
//

#import "KSTUSResumableUpload.h"

#import "AFNetworking.h"

#define HTTP_PATCH @"PATCH"
#define HTTP_POST @"POST"
#define HTTP_HEAD @"HEAD"
#define HTTP_OFFSET @"Offset"
#define HTTP_FINAL_LENGTH @"Final-Length"
#define HTTP_LOCATION @"Location"
#define REQUEST_TIMEOUT 30
#define UPLOAD_URL @"http://10.10.10.47:9000/upload/"//http://master.tus.io/files
#define TUS_BUFSIZE (128*1024)

@interface KSTUSResumableUpload ()

@property (nonatomic,strong) ALAsset *uploadingAsset;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic,assign) long long bytesWritten;
@property (nonatomic,assign) long long uploadOffset;
@property (nonatomic,assign) long long assetDataLength;
@property (nonatomic,assign) BOOL uploadCancelled;
@property (nonatomic,strong) NSString *assetURL;
@property (nonatomic,strong) NSString *uploadURL;
@property (nonatomic,strong) NSData *chunkData;

@end

@implementation KSTUSResumableUpload

- (id)initForALAsset:(ALAsset *)asset
         andDelegate:(id<KSTUSResumableUploadProtocol>)delegate {
    
    self = [super init];
    if (self) {
        _delegate = delegate;
        _uploadingAsset = asset;
        _uploadOffset = 0;
        _uploadCancelled = NO;
        ALAssetRepresentation *rep = [asset defaultRepresentation];
        _assetDataLength = rep.size;
        _assetURL = [rep.url absoluteString];
        rep = nil;
        [self startUpload];
    }
    return self;
}

- (id)initForALAssetWithURL:(NSURL*)assetURL
                   withName:(NSString*)assetName
                andDelegate:(id<KSTUSResumableUploadProtocol>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _assetURL = [assetURL absoluteString];
        _uploadOffset = 0;
        _uploadCancelled = NO;
        [self startUploadForURL:assetURL];
    }
    return self;
}

- (void)startUploadForURL:(NSURL*)assetURL {
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    [_assetsLibrary assetForURL:assetURL resultBlock: ^(ALAsset *asset){
        
        if (asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            _assetDataLength = rep.size;
            rep = nil;
            _uploadingAsset = asset;
            [self startUpload];
        }
        else {
            [_delegate uploadFailled];
            UIAlertView *allert = [[UIAlertView alloc] initWithTitle:nil message:@"Could not locate assets file!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [allert show];
        }
    } failureBlock:^(NSError *error) {
        
        [_delegate uploadFailled];
        UIAlertView *allert = [[UIAlertView alloc] initWithTitle:nil message:@"Could not locate assets file!" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [allert show];
    }];
}

- (void)startUpload {
    
    NSString *uploadUrl = [[self resumableUploads] valueForKey:_assetURL];
    if (uploadUrl && [uploadUrl isKindOfClass:[NSString class]] && [uploadUrl length]) {
        _uploadURL = uploadUrl;
        [self checkFile];
    }
    else {
        [self createFile];
    }
}

- (void)createFile {
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%llu", _assetDataLength], HTTP_FINAL_LENGTH,
                             @"0", @"Content-Length", nil];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:UPLOAD_URL]];
    NSMutableURLRequest *afRequest = [httpClient requestWithMethod:HTTP_POST path:UPLOAD_URL parameters:nil];
    [afRequest setTimeoutInterval:REQUEST_TIMEOUT];
    [afRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [afRequest setHTTPShouldHandleCookies:NO];
    [afRequest setAllHTTPHeaderFields:headers];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responseHeaders = operation.response.allHeaderFields;
        if (responseHeaders && [responseHeaders isKindOfClass:[NSDictionary class]]) {
            if ([responseHeaders valueForKey:HTTP_LOCATION]) {
                _uploadURL = [responseHeaders valueForKey:HTTP_LOCATION];
                NSLog(@"Created resumable upload at %@ for asset URL %@", _uploadURL, _assetURL);
                NSURL* fileURL = [self resumableUploadsFilePath];
                NSMutableDictionary* resumableUploads = [self resumableUploads];
                [resumableUploads setValue:_uploadURL forKey:_assetURL];
                BOOL success = [resumableUploads writeToURL:fileURL atomically:YES];
                if (!success) {
                    NSLog(@"Unable to save resumableUploads file");
                }
                _bytesWritten = 0;
                [self uploadFile];
            }
            else {
                NSLog(@"invalid create file header response");
            }
        }
        else {
            NSLog(@"no create file header response");
        }
        
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"failled to create file");
	}];
	[operation start];
}

- (void)checkFile {
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:_uploadURL]];
    NSMutableURLRequest *afRequest = [httpClient requestWithMethod:HTTP_HEAD path:_uploadURL parameters:nil];
    [afRequest setTimeoutInterval:REQUEST_TIMEOUT];
    [afRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [afRequest setHTTPShouldHandleCookies:NO];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode != 200) {
            NSLog(@"Server responded with %i. Restarting upload", (int)operation.response.statusCode);
            [self createFile];
        }
        else {
            NSDictionary *responseHeaders = operation.response.allHeaderFields;
            if (responseHeaders && [responseHeaders isKindOfClass:[NSDictionary class]]) {
                if ([responseHeaders valueForKey:HTTP_OFFSET]) {
                    NSString *rangeHeader = [responseHeaders valueForKey:HTTP_OFFSET];
                    _uploadOffset = [rangeHeader longLongValue];
                    NSLog(@"Resumable upload at %@ for %@ from %lld (%@)", _uploadURL, _assetURL, _uploadOffset, rangeHeader);
                }
                else {
                    _uploadOffset = 0;
                    NSLog(@"Restarting upload at %@ for %@", _uploadURL, _assetURL);
                }
            }
            else {
                _uploadOffset = 0;
                NSLog(@"Restarting upload at %@ for %@", _uploadURL, _assetURL);
            }
            _bytesWritten = _uploadOffset;
            [self uploadFile];
        }
        
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"failled to check file");
	}];
	[operation start];
}

- (void)uploadFile {
    
    if (_assetDataLength > _bytesWritten && !_uploadCancelled) {
        NSRange chunkRange = NSMakeRange((NSUInteger)_bytesWritten, TUS_BUFSIZE);
        if (_bytesWritten + TUS_BUFSIZE > _assetDataLength) {
            chunkRange.length = (NSUInteger)(_assetDataLength - _bytesWritten);
        }
        [self uploadFileChunkWithRange:chunkRange];
    }
    else if (_uploadCancelled) {
        [_delegate uploadPaused];
    }
    else {
        NSMutableDictionary* resumableUploads = [self resumableUploads];
        [resumableUploads removeObjectForKey:_assetURL];
        BOOL success = [resumableUploads writeToURL:[self resumableUploadsFilePath] atomically:YES];
        if (!success) {
            NSLog(@"Unable to save resumableUploads file");
        }
        [_delegate uploadFinished];
    }
}

- (void)uploadFileChunkWithRange:(NSRange)chunkRange {
    
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"%lld", _uploadOffset], HTTP_OFFSET,
                             @"application/offset+octet-stream", @"Content-Type",
                             [NSString stringWithFormat:@"%i", (int)[_chunkData length]], @"Content-Length", nil];
    
    _chunkData = nil;
    _chunkData = [self chunkDataForRange:chunkRange];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:_uploadURL]];
    NSMutableURLRequest *afRequest = [httpClient requestWithMethod:HTTP_PATCH path:_uploadURL parameters:nil];
    [afRequest setTimeoutInterval:REQUEST_TIMEOUT];
    [afRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [afRequest setHTTPShouldHandleCookies:NO];
    [afRequest setAllHTTPHeaderFields:headers];
    [afRequest setHTTPBody:_chunkData];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        [_delegate uploadProgress:(float)(_bytesWritten + bytesWritten)/(float)_assetDataLength];
	}];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (operation.response.statusCode != 200) {
            
        }
        else {
            _bytesWritten += chunkRange.length;
            _uploadOffset = _bytesWritten;
            _chunkData = nil;
            [_delegate uploadProgress:(float)_bytesWritten/(float)_assetDataLength];
            [self uploadFile];
        }
        
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"failled upload chunk");
	}];
	[operation start];
}

- (NSData*)chunkDataForRange:(NSRange)chunkRange {
    ALAssetRepresentation *representation = [_uploadingAsset defaultRepresentation];
    uint8_t *buffer = malloc((long)representation.size);
    NSUInteger buffered = [representation getBytes:buffer fromOffset:chunkRange.location length:chunkRange.length error:nil];
    
    return [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
}

#pragma mark - Private Methods
- (NSMutableDictionary*)resumableUploads {
    
    static id resumableUploads = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL* resumableUploadsPath = [self resumableUploadsFilePath];
        resumableUploads = [NSMutableDictionary dictionaryWithContentsOfURL:resumableUploadsPath];
        if (!resumableUploads) {
            resumableUploads = [[NSMutableDictionary alloc] init];
        }
    });
    return resumableUploads;
}

- (NSURL*)resumableUploadsFilePath {
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* directories = [fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
    NSURL* applicationSupportDirectoryURL = [directories lastObject];
    NSString* applicationSupportDirectoryPath = [applicationSupportDirectoryURL absoluteString];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:applicationSupportDirectoryPath isDirectory:&isDirectory]) {
        NSError* error = nil;
        BOOL success = [fileManager createDirectoryAtURL:applicationSupportDirectoryURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:&error];
        if (!success) {
            NSLog(@"Unable to create %@ directory due to: %@", applicationSupportDirectoryURL, error);
        }
    }
    return [applicationSupportDirectoryURL URLByAppendingPathComponent:@"TUSResumableUploads.plist"];
}

- (void)cancelUpload {
    _uploadCancelled = YES;
}

@end
