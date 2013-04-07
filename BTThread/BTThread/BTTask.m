//
//  BTTask.m
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTTask.h"

@implementation BTTask
- (void)cancel {
  _canceled = YES;
}

- (BOOL)isCanceled {
  return _canceled;
}

- (void)run {
  [NSThread sleepForTimeInterval:0.2];
}

@end
