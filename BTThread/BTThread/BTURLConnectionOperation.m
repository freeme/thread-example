//
//  BTURLConnectionOperation.m
//  BTThread
//
//  Created by Gary on 13-5-1.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTURLConnectionOperation.h"

@interface BTURLConnectionOperation()

///------------------------
/// @name Accessing Streams
///------------------------
//
///**
// The input stream used to read data to be sent during the request.
// 
// @discussion This property acts as a proxy to the `HTTPBodyStream` property of `request`.
// */
//@property (nonatomic, retain) NSInputStream *inputStream;
//
///**
// The output stream that is used to write data received until the request is finished.
// 
// @discussion By default, data is accumulated into a buffer that is stored into `responseData` upon completion of the request. When `outputStream` is set, the data will not be accumulated into an internal buffer, and as a result, the `responseData` property of the completed request will be `nil`. The output stream will be scheduled in the network thread runloop upon being set.
// */
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSOutputStream *outputStream;
@property (nonatomic, retain) NSURLRequest *request;
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSData *responseData;
@property (nonatomic, retain) NSError *error;

- (void)finish;
@end

@implementation BTURLConnectionOperation

- (void)dealloc {
  self.request = nil;
  self.response = nil;
  self.responseData = nil;
  [self.outputStream close];
  self.outputStream = nil;
  self.error = nil;
  [super dealloc];
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
  self = [super init];
  if (self) {
    self.request = urlRequest;
  }
  return self;
}

/**
 Subclass should overwrite this method
 */
- (void)concurrentExecution {
  _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
  
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  for (NSString *runLoopMode in self.runLoopModes) {
    [self.connection scheduleInRunLoop:runLoop forMode:runLoopMode];
    [self.connection scheduleInRunLoop:runLoop forMode:runLoopMode];
  }
  
  [self.connection start];
  

}

/**
 Subclass should overwrite this method
 */
- (void)cancelConcurrentExecution {
  NSDictionary *userInfo = nil;
  if ([self.request URL]) {
    userInfo = [NSDictionary dictionaryWithObject:[self.request URL] forKey:NSURLErrorFailingURLErrorKey];
  }
  self.error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo];
  
  if (self.connection) {
    [self.connection cancel];
    
    // Manually send this delegate message since `[self.connection cancel]` causes the connection to never send another message to its delegate
    [self performSelector:@selector(connection:didFailWithError:) withObject:self.connection withObject:self.error];
  }
}


#pragma mark -
#pragma mark NSURLConnectionDataDelegate

/*
 in rare cases, for example in the case of an HTTP load where the content type of the load data is multipart/x-mixed-replace, the delegate will receive more than one connection:didReceiveResponse: message. In the event this occurs, delegates should discard all data previously delivered by connection:didReceiveData:, and should be prepared to handle the, potentially different, MIME type reported by the newly reported URL response.
 The only case where this message is not sent to the delegate is when the protocol implementation encounters an error before a response could be created.
 
 */
- (void)connection:(NSURLConnection __unused *)connection didReceiveResponse:(NSURLResponse *)response {
  self.response = response;
  self.outputStream = [NSOutputStream outputStreamToMemory];
  [self.outputStream open];
}

- (void)connection:(NSURLConnection __unused *)connection didReceiveData:(NSData *)data {
  if ([self.outputStream hasSpaceAvailable]) {
    const uint8_t *dataBuffer = (uint8_t *) [data bytes];
    [self.outputStream write:&dataBuffer[0] maxLength:[data length]];
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    //TODO: 
//    self.totalBytesRead += [data length];
//    
//    if (self.downloadProgress) {
//      self.downloadProgress([data length], self.totalBytesRead, self.response.expectedContentLength);
//    }
  });
}

- (void)connectionDidFinishLoading:(NSURLConnection __unused *)connection {
  self.responseData = [_outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
  
  [self.outputStream close];
  self.outputStream = nil;
  
  [self finish];
  self.connection = nil;
}

- (void)connection:(NSURLConnection __unused *)connection didFailWithError:(NSError *)error {
  self.error = error;
  
  [self.outputStream close];
  self.outputStream = nil;
  [self finish];
  self.connection = nil;
}

@end
