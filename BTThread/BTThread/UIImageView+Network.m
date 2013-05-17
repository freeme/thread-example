//
//  UIImageView+Network.m
//  BTThread
//
//  Created by Gary on 13-5-6.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//
#import <objc/runtime.h>
#import "UIImageView+Network.h"
#import "BTCache.h"
typedef NS_OPTIONS(NSUInteger, UIImageViewRequestFlag) {
  UIImageViewRequestFlagNone        = 0,
  UIImageViewRequestFlagAutoCancel  = 1 << 0,
  UIImageViewRequestFlagAutoReload  = 1 << 1,
  UIImageViewRequestFlagIsLoaded    = 1 << 2,
};

static char kBTImageRequestOperationObjectKey = 1;
static char kBTImageRequestURLObjectKey = 2;
static char kBTImageRequestFlagObjectKey = 3;

@interface UIImageView (_Network)
@property (nonatomic, retain) BTURLRequestOperation *imageRequestOperation;
@property (nonatomic, retain) NSURL *requestURL;
@property (nonatomic, retain) NSNumber *requestFlags;
@property (nonatomic) BOOL isLoaded;

//- (BOOL)getBoolValueForFlag:(UIImageViewRequestFlag)flag;
//- (void)setBoolValue:(BOOL)value forFlag:(UIImageViewRequestFlag)flag;

@end

@implementation UIImageView (_Network)
@dynamic imageRequestOperation;
@dynamic requestURL;
@dynamic requestFlags;
@dynamic isLoaded;
@end

@implementation UIImageView (Network)


//+ (void)initialize {
//  Class klass = [UIView class];
//  method_exchangeImplementations(class_getInstanceMethod(klass,@selector(drawRect:)),class_getInstanceMethod(klass, @selector(__drawRect:)));
////  method_exchangeImplementations(class_getInstanceMethod(klass,@selector(viewWillDisappear:)),class_getInstanceMethod(klass, @selector(__replacedViewWillDisappear:)));
//}

- (void)__drawRect:(CGRect)rect {
  NSLog(@"__drawRect");
}

- (void)dealloc {
  [self cancelImageRequestOperation];
  self.requestURL = nil;
  self.requestFlags = nil;
  [super dealloc];
}

- (BTURLRequestOperation *)imageRequestOperation {
  return (BTURLRequestOperation *)objc_getAssociatedObject(self, &kBTImageRequestOperationObjectKey);
}

- (void)setImageRequestOperation:(BTURLRequestOperation *)imageRequestOperation {
  objc_setAssociatedObject(self, &kBTImageRequestOperationObjectKey, imageRequestOperation,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSURL *)requestURL {
  return (NSURL *)objc_getAssociatedObject(self, &kBTImageRequestURLObjectKey);
}

- (void)setRequestURL:(NSURL *)requestURL {
  objc_setAssociatedObject(self, &kBTImageRequestURLObjectKey, requestURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)requestFlags {
  return (NSNumber*)objc_getAssociatedObject(self, &kBTImageRequestFlagObjectKey);
}

- (void)setRequestFlags:(NSNumber *)requestFlags {
  objc_setAssociatedObject(self, &kBTImageRequestFlagObjectKey, requestFlags,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)getBoolValueForFlag:(UIImageViewRequestFlag)flag {
  NSNumber *flagsObj = (NSNumber*)objc_getAssociatedObject(self, &kBTImageRequestFlagObjectKey);
  return [flagsObj integerValue]&flag;
}

- (void)setBoolValue:(BOOL)value forFlag:(UIImageViewRequestFlag)flag {
  NSNumber *flagsObj = (NSNumber*)objc_getAssociatedObject(self, &kBTImageRequestFlagObjectKey);
  NSInteger flagsValue = [flagsObj integerValue];
  if (value) {
    flagsObj = [NSNumber numberWithInteger:flagsValue|flag];
  } else {
    flagsObj = [NSNumber numberWithInteger:(flagsValue&=~flag)];
  }
  objc_setAssociatedObject(self, &kBTImageRequestFlagObjectKey, flagsObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isAutoCancelRequest {
  return [self getBoolValueForFlag:UIImageViewRequestFlagAutoCancel];
}

- (void)setIsAutoCancelRequest:(BOOL)value {
  [self setBoolValue:value forFlag:UIImageViewRequestFlagAutoCancel];
}

- (BOOL)isAutoReloadRequest {
  return [self getBoolValueForFlag:UIImageViewRequestFlagAutoReload];
}

- (void)setIsAutoReloadRequest:(BOOL)value {
  [self setBoolValue:value forFlag:UIImageViewRequestFlagAutoReload];
}

- (BOOL)isLoaded {
  return [self getBoolValueForFlag:UIImageViewRequestFlagIsLoaded];
}

- (void)setIsLoaded:(BOOL)value {
  [self setBoolValue:value forFlag:UIImageViewRequestFlagIsLoaded];
}

+ (NSOperationQueue *)sharedImageRequestOperationQueue {
  static NSOperationQueue *__imageRequestOperationQueue = nil;
  static dispatch_once_t __onceToken;
  dispatch_once(&__onceToken, ^{
    __imageRequestOperationQueue = [[NSOperationQueue alloc] init];
    [__imageRequestOperationQueue setMaxConcurrentOperationCount:3];
  });
  
  return __imageRequestOperationQueue;
}

+ (NSCache*)sharedMemoryCache {
  static NSCache *__memoryCache = nil;
  static dispatch_once_t __onceToken;
  dispatch_once(&__onceToken, ^{
    __memoryCache = [[NSCache alloc] init];
    [__memoryCache setCountLimit:20];
  });
  return __memoryCache;
}

//+ (BTCache*)sharedCache {
//  static BTCache *__memoryCache = nil;
//  static dispatch_once_t __onceToken;
//  dispatch_once(&__onceToken, ^{
//    __memoryCache = [[BTCache alloc] init];
//  });
//  return __memoryCache;
//}

- (void)setImageWithURL:(NSURL *)url {
  if (![self.requestURL isEqual:url]) {
    self.requestURL = url;
    [self cancelImageRequestOperation];
    self.isLoaded = NO;
    self.image = nil;
//    NSLog(@"absoluteString=%@",[url absoluteString]);
//    NSLog(@"resourceSpecifier=%@",[url resourceSpecifier]);
//    UIImage *img = [[[self class] sharedMemoryCache] objectForKey:url];
//    if (img) {
//      self.image = img;
//    } else {
//      [self sendRequestDalayed];
//    }
    [[BTCache sharedCache] imageForURL:url completionBlock:^(UIImage *image, NSURL *url) {
      if ([self.requestURL isEqual:url]) {
        if (image) {
          self.image = image;
        } else {
          [self sendRequestDalayed];
        }
      }
    }];
  }

}

- (void)sendRequestDalayed {
  [self performSelector:@selector(sendRequest) withObject:nil afterDelay:0.25];
}

- (void)sendRequest {
  NSURL *url = self.requestURL;

  static int testNum = 0;
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  //[request setHTTPShouldHandleCookies:NO];
  //[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
  BTURLRequestOperation *operation = [[BTURLRequestOperation alloc] initWithRequest:request delegate:self];
  if ([url isFileURL]) { //优先加载本地文件
    //NSLog(@"isFileURL = YES fileReferenceURL=%@ filePathURL=%@", [url fileReferenceURL],[url filePathURL]);
    //TODO: if it's a local file, send to an other queue? we need to load it first.
    //Step1: 检查本地有没有
    //Step2: 有，直接异步加载
    //Step3: 没有，发网络请求
    [operation setQueuePriority:NSOperationQueuePriorityHigh];
  } else {
    [operation setQueuePriority:NSOperationQueuePriorityNormal];
  }

  operation.name = [NSString stringWithFormat:@"op%d",testNum++];
  self.imageRequestOperation = operation;
  [[[self class] sharedImageRequestOperationQueue] addOperation:operation];
  [operation release];
}

- (void)cancelImageRequestOperation {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
  BTURLRequestOperation *operation = self.imageRequestOperation;
  if (operation) {
    [operation cancel];
    [operation setDelegate:nil];
    self.imageRequestOperation = nil;
  }
}


- (void)reloadImageRequestIfNeed {
  if (self.isAutoReloadRequest && self.isLoaded == NO) {
    [self sendRequestDalayed];
  }
}

- (void)cancelImageRequestIfNeed {
  if (self.isAutoCancelRequest) {
    [self cancelImageRequestOperation];
  }
}

#pragma mark BTURLRequestDelegate
- (void)requestStarted:(BTURLRequestOperation *)operation {
  
}
- (void)requestFinished:(BTURLRequestOperation *)operation {
  NSInteger length = [operation.responseData length];
  if (length > 0) {
    
    UIImage *image = [UIImage imageWithData:operation.responseData];
    self.image = image;
    
    [[BTCache sharedCache] setImage:image forURL:[operation.request URL]];
    
    //[[[self class] sharedMemoryCache] setObject:image forKey:[operation.request URL] cost:length];
    
    self.alpha = 0.3;
    [UIView beginAnimations:@"" context:NULL];
    [UIView setAnimationDuration:0.3];
    //[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.alpha = 1.0;
    
    [UIView commitAnimations];
    //self.image = [UIImage imageWithCGImage:[image CGImage] scale:[[UIScreen mainScreen] scale] orientation:image.imageOrientation];
//    [self setNeedsDisplay];
//    self.image = [UIImage imageWithCGImage:[image CGImage] scale:[[UIScreen mainScreen] scale] orientation:image.imageOrientation];
    self.isLoaded = YES;
  }
}
- (void)requestFailed:(BTURLRequestOperation *)operation {
  
}

@end
