//
//  BTURLConnectionOperation.h
//  BTThread
//
//  Created by Gary on 13-5-1.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTConcurrentOperation.h"

@class BTURLRequestOperation;
@protocol BTURLRequestDelegate <NSObject>

@optional
- (void)requestStarted:(BTURLRequestOperation *)operation;
- (void)requestFinished:(BTURLRequestOperation *)operation;
- (void)requestFailed:(BTURLRequestOperation *)operation;

// When a delegate implements this method, it is expected to process all incoming data itself
// This means that responseData / responseString / downloadDestinationPath etc are ignored
// You can have the request call a different method by setting didReceiveDataSelector
- (void)request:(BTURLRequestOperation *)operation didReceiveData:(NSData *)data;

@end

@interface BTURLRequestOperation : BTConcurrentOperation<NSURLConnectionDataDelegate> {
  id<BTURLRequestDelegate> _delegate;
  BOOL _receiveDataExternally;
}

- (id)initWithRequest:(NSURLRequest*)request delegate:(id<BTURLRequestDelegate>)delegate;

- (void)setDelegate:(id<BTURLRequestDelegate>)delegate;
/**
 The request used by the operation's connection.
 */
@property (readonly, nonatomic, retain) NSURLRequest *request;

/**
 The last response received by the operation's connection.
 */
@property (readonly, nonatomic, retain) NSURLResponse *response;

/**
 The error, if any, that occurred in the lifecycle of the request.
 */
@property (readonly, nonatomic, retain) NSError *error;

///----------------------------
/// @name Getting Response Data
///----------------------------

/**
 The data received during the request.
 */
@property (readonly, nonatomic, retain) NSData *responseData;


///---------------------------------------------
/// @name Managing Request Operation Information
///---------------------------------------------

/**
 The user info dictionary for the receiver.
 */
@property (nonatomic, retain) NSDictionary *userInfo;

///------------------------------------------------------
/// @name Initializing an AFURLConnectionOperation Object
///------------------------------------------------------

/**
 Initializes and returns a newly allocated operation object with a url connection configured with the specified url request.
 
 @param urlRequest The request object to be used by the operation connection.
 
 @discussion This is the designated initializer.
 */
- (id)initWithRequest:(NSURLRequest *)urlRequest;

@end
