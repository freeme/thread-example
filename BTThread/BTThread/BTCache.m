//
//  BTCache.m
//  BTThread
//
//  Created by He baochen on 13-5-17.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTCache.h"
#import "NSStringAdditions.h"

static inline NSString* cachePathForKey(NSString* directory, NSString* key) {
	return [directory stringByAppendingPathComponent:key];
}

inline static NSString *keyForURL(NSURL *url) {
	return [url absoluteString];
}

@interface BTIOBlockOperation : NSBlockOperation
@property(nonatomic,copy) NSString* key;
@end

@implementation BTIOBlockOperation



@end


@implementation BTCache
+ (id)sharedCache {
  static BTCache *__sharedCache = nil;
	static dispatch_once_t onceToken;
  
	dispatch_once(&onceToken, ^{
		__sharedCache = [[BTCache alloc] init];
	});
  
	return __sharedCache;
}

- (id) init {
  self = [super init];
  if (self) {
    _memoryCache = [[NSCache alloc] init];
    [_memoryCache setName:@"BTCache-Memory"];
    [_memoryCache setCountLimit:1];
    
    _diskOperationQueue = [[NSOperationQueue alloc] init];
    [_diskOperationQueue setMaxConcurrentOperationCount:1];
    
    _networkOperationQueue = [[NSOperationQueue alloc] init];
    [_networkOperationQueue setMaxConcurrentOperationCount:3];
    
    _defaultManager = [[NSFileManager defaultManager] retain];
    NSString* sysCachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    _cachesDirectory = [[[sysCachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"BTCache"] copy];
    NSLog(@"_cachesDirectory:%@",_cachesDirectory);
    [_defaultManager createDirectoryAtPath:_cachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
  }
  return self;
}

- (NSString*)filePathForKey:(NSString*)key {
  return cachePathForKey(_cachesDirectory, key);
}

- (void) imageForURL:(NSURL*)url completionBlock:(void (^)(UIImage *image, NSURL *url))completion {
  NSString* key = [[url absoluteString] sha1Hash];
  __block UIImage *img = [[_memoryCache objectForKey:key] retain];
  if (img) {
    if(completion) {
      completion(img,url);
      [img release];
    }
  } else {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    BTIOBlockOperation *readExistInDisk = [BTIOBlockOperation blockOperationWithBlock:^{
      NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
      NSLog(@"readExistInDisk.key = %@", key);
      img = [[_memoryCache objectForKey:key] retain];
      if (!img) {
        BOOL exist = [_defaultManager fileExistsAtPath:[self filePathForKey:key]];
        if (exist) {
          @try {
            img = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForKey:key]] retain];
          } @catch (NSException* e) {
            // Surpress any unarchiving exceptions and continue with nil
          }
        }
      }
      
      if (img) {
        [_memoryCache setObject:img forKey:key cost:(img.size.width*img.size.height*img.scale)];
//        UIGraphicsBeginImageContext(CGSizeMake(44, 44));
//        [img drawInRect:CGRectMake(0, 0, 44, 44)];
//        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        [smallImage retain];
      }
      if(completion) {
        [mainQueue addOperationWithBlock:^{
          completion(img,url);
          [img release];
        }];
      }

    
//      UIImage *smallImage = nil;
//      if(completion) {
//        [mainQueue addOperationWithBlock:^{
//          completion(smallImage,url);
//          [smallImage release];
//          [img release];
//        }];
//      }
      [pool release];
    }];
    [readExistInDisk setQueuePriority:NSOperationQueuePriorityNormal];
    readExistInDisk.key = key;
    [_diskOperationQueue addOperation:readExistInDisk];
  }

}


- (void)setImage:(UIImage*)image forURL:(NSURL*)url {
   NSString* key = [[url absoluteString] sha1Hash];
  [_memoryCache setObject:image forKey:key cost:(image.size.width*image.size.height*image.scale)];
  NSBlockOperation *writeToDisk = [NSBlockOperation blockOperationWithBlock:^{
    BOOL exist = [_defaultManager fileExistsAtPath:[self filePathForKey:key]];
    if (!exist) {
      @try {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:image];
        [data writeToFile:[self filePathForKey:key] atomically:YES];
      } @catch (NSException* e) {
        // Something went wrong, but we'll fail silently.
      }
    }
    
  }];
  [writeToDisk setQueuePriority:NSOperationQueuePriorityLow];
  [_diskOperationQueue addOperation:writeToDisk];
}

- (void)cancelImageForURL:(NSURL*)url {
  NSString* key = [[url absoluteString] sha1Hash];
  NSArray *ops = [[_diskOperationQueue operations] copy];
  for (NSBlockOperation *op in ops) {
    if ([op isKindOfClass:[BTIOBlockOperation class]]) {
      if ([((BTIOBlockOperation*)op).key isEqualToString:key]) {
        [op cancel];
        NSLog(@"--------------");
        break;
        
      }
    }
  }
  [ops release];
}

- (void)clearAll {
  [_memoryCache removeAllObjects];
}


@end
