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
    [__imageRequestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
  });
  
  return __imageRequestOperationQueue;
}
- (void)setImageWithURL:(NSURL *)url {
  //UIViewController *viewController;
}

- (void)cancelImageRequestOperation {
  [self.imageRequestOperation cancel];
  [self.imageRequestOperation setDelegate:nil];
  self.imageRequestOperation = nil;
}

- (void)reloadImageRequestIfNeed {
  
}
@end
