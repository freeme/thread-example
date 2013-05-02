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
//@property (nonatomic, retain) NSOutputStream *outputStream;

@end

@implementation BTURLConnectionOperation

- (void)dealloc {
  [_request release];
  _request = nil;
  if (_outputStream) {
    [_outputStream close];
    [_outputStream release];
    _outputStream = nil;
  }
  [super dealloc];
}

- (id)initWithRequest:(NSURLRequest *)urlRequest {
  self = [super init];
  if (self) {
    _request = [urlRequest retain];
    _outputStream = [[NSOutputStream outputStreamToMemory] retain];
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
    [_connection scheduleInRunLoop:runLoop forMode:runLoopMode];
    [_connection scheduleInRunLoop:runLoop forMode:runLoopMode];
  }
  
  [_connection start];
  

}

/**
 Subclass should overwrite this method
 */
- (void)cancelConcurrentExecution {
}


@end
