//
//  UIImageView+Network.m
//  BTThread
//
//  Created by Gary on 13-5-6.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//
#import <objc/runtime.h>
#import "UIImageView+Network.h"


static char kBTImageRequestOperationObjectKey;
@interface UIImageView (_Network)
@property (readwrite, nonatomic, retain) BTURLRequestOperation *imageRequestOperation;
@end

@implementation UIImageView (_Network)
@dynamic imageRequestOperation;
@end

@implementation UIImageView (Network)

- (void)dealloc {
  [self cancelImageRequestOperation];
  [super dealloc];
}

- (BTURLRequestOperation *)imageRequestOperation {
  return (BTURLRequestOperation *)objc_getAssociatedObject(self, &kBTImageRequestOperationObjectKey);
}

- (void)setImageRequestOperation:(BTURLRequestOperation *)imageRequestOperation {
  objc_setAssociatedObject(self, &kBTImageRequestOperationObjectKey, imageRequestOperation,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSOperationQueue *)sharedImageRequestOperationQueue {
  static NSOperationQueue *__imageRequestOperationQueue = nil;
  static dispatch_once_t __onceToken;
  dispatch_once(&__onceToken, ^{
    __imageRequestOperationQueue = [[NSOperationQueue alloc] init];
    [__imageRequestOperationQueue setMaxConcurrentOperationCount:1];
  });
  
  return __imageRequestOperationQueue;
}
- (void)setImageWithURL:(NSURL *)url {
  //TODO: check if need cancel
  self.image = nil;
  [self cancelImageRequestOperation];
  if ([url isFileURL]) {
    //NSLog(@"isFileURL = YES fileReferenceURL=%@ filePathURL=%@", [url fileReferenceURL],[url filePathURL]);
  }
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//[request setHTTPShouldHandleCookies:NO];
//[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
  BTURLRequestOperation *operation = [[BTURLRequestOperation alloc] initWithRequest:request delegate:self];
  self.imageRequestOperation = operation;
  [[[self class] sharedImageRequestOperationQueue] addOperation:operation];
  [operation release];
}

- (void)cancelImageRequestOperation {
  [self.imageRequestOperation cancel];
  [self.imageRequestOperation setDelegate:nil];
  self.imageRequestOperation = nil;
}


- (void)reloadImageRequestIfNeed {
  
}

#pragma mark BTURLRequestDelegate
- (void)requestStarted:(BTURLRequestOperation *)operation {
  
}
- (void)requestFinished:(BTURLRequestOperation *)operation {

  if ([operation.responseData length] > 0) {
    UIImage *image = [UIImage imageWithData:operation.responseData];
    self.image = image;
    //self.image = [UIImage imageWithCGImage:[image CGImage] scale:[[UIScreen mainScreen] scale] orientation:image.imageOrientation];
//    [self setNeedsDisplay];
//    self.image = [UIImage imageWithCGImage:[image CGImage] scale:[[UIScreen mainScreen] scale] orientation:image.imageOrientation];
  }
}
- (void)requestFailed:(BTURLRequestOperation *)operation {
  
}

@end
