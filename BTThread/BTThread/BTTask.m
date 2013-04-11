//
//  BTTask.m
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTTask.h"
#import "BTThreadPool.h"

static NSInteger taskIDSeed = 0;

@implementation BTTask

- (id)init {
  self = [super init];
  if (self) {
    _taskID = taskIDSeed++;
  }
  return self;
}
- (void)cancel {
  _canceled = YES;
  [_threadPool cancelTask:self];
}

- (BOOL)isCanceled {
  return _canceled;
}

- (void)run {
  [NSThread sleepForTimeInterval:1.2];
}

- (NSInteger) taskID {
  return _taskID;
}

- (BTThreadPool *) threadPool {
  return _threadPool;
}

- (void)setThreadPool:(BTThreadPool *)threadPool {
  _threadPool = threadPool;
}

@end
