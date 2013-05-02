//
//  BTHTTPOperation.m
//  BTThread
//
//  Created by Gary on 13-5-2.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTHTTPOperation.h"

@interface BTHTTPOperation()

/**
 The last response received by the operation's connection.
 */
@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, retain) NSOutputStream *outputStream;

@end

@implementation BTHTTPOperation

/*
 in rare cases, for example in the case of an HTTP load where the content type of the load data is multipart/x-mixed-replace, the delegate will receive more than one connection:didReceiveResponse: message. In the event this occurs, delegates should discard all data previously delivered by connection:didReceiveData:, and should be prepared to handle the, potentially different, MIME type reported by the newly reported URL response.
 The only case where this message is not sent to the delegate is when the protocol implementation encounters an error before a response could be created.
 
 */
- (void)connection:(NSURLConnection __unused *)connection didReceiveResponse:(NSURLResponse *)response {

  self.response = response;
  self.outputStream = [NSOutputStream outputStreamToMemory];
  [self.outputStream open];
}

@end
