//
//  BlockDownloader.m
//  AnsellInterceptApp
//
//  Created by andrew on 2/6/15.
//  Copyright (c) 2015 Ansell. All rights reserved.
//

#import "AB_BlockDownloader.h"

@interface AB_BlockDownloader()
{
    NSMutableData* downloadedData;
    long long expectedLength;
    
    NSMutableURLRequest* request;
    NSURLConnection* connection;
    
    NSArray* retainSelf;
    
    dispatch_semaphore_t sema;
    NSError* failError;
}

@end

@implementation AB_BlockDownloader

@synthesize progress;
@synthesize success;
@synthesize failure;

+ (AB_BlockDownloader*) getURL:(NSURL*)url
{
    return [[AB_BlockDownloader alloc] initWithURL:url verb:@"GET"];
}

- (id) initWithURL:(NSURL*)url verb:(NSString*)verb
{
    if ( self == [super init] )
    {
        request = [NSMutableURLRequest requestWithURL:url
                                          cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                      timeoutInterval:60*3];
        
        [request setHTTPMethod:verb];
    }
    
    return self;
}

- (void) call
{
    failError = nil;
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                          forMode:NSDefaultRunLoopMode];
    [connection start];
    retainSelf = @[self];
}

- (void) cleanup
{
    retainSelf = nil;
    if ( sema != NULL )
    {
        dispatch_semaphore_signal(sema);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    failure(error);
    failError = error;
    [self cleanup];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    expectedLength = response.expectedContentLength;
    self.progress(0, expectedLength);
    downloadedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [downloadedData appendData:data];
    self.progress(downloadedData.length, expectedLength);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.success(downloadedData);
    [self cleanup];
}

- (NSData*) callSyncWithError:(NSError**)err
{
    sema = dispatch_semaphore_create(0);
    [self call];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

    *err = failError;
    if ( !failError )
    {
        return downloadedData;
    }
    
    return nil;
}

@end
