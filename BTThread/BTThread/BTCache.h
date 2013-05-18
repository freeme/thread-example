//
//  BTCache.h
//  BTThread
//
//  Created by He baochen on 13-5-17.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTCache : NSObject {
  NSCache* _memoryCache;
  NSOperationQueue *_diskOperationQueue;
  NSOperationQueue *_networkOperationQueue;
  NSFileManager* _defaultManager;
  NSString *_cachesDirectory;
}

+ (id)sharedCache;

- (void)imageForURL:(NSURL*)url completionBlock:(void (^)(UIImage *image, NSURL *url))completion;
- (void)setImage:(UIImage*)image forURL:(NSURL*)url;
- (void)cancelImageForURL:(NSURL*)url;
- (void)clearAll;
@end
