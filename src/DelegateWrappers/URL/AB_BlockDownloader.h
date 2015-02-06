//
//  NSURLConnectionDelegate.h
//  AnsellInterceptApp
//
//  Created by andrew on 2/6/15.
//  Copyright (c) 2015 Ansell. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DownloadProgressBlock)(long long currentSize, long long totalSize);
typedef void (^DownloadSuccessBlock)(NSData* data);
typedef void (^DownloadFailureBlock)(NSError* error);

@interface AB_BlockDownloader : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property(strong) DownloadProgressBlock progress;
@property(strong) DownloadSuccessBlock success;
@property(strong) DownloadFailureBlock failure;

+ (AB_BlockDownloader*) getURL:(NSURL*)url;
- (void) call;
- (NSData*) callSyncWithError:(NSError**)err;

@end
