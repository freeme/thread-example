//
//  BTLockThreadPool.m
//  BTThread
//
//  Created by Gary on 13-4-11.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTLockThreadPool.h"

@implementation BTLockThreadPool

- (id) initWithPoolSize:(int)size {
  self =[super init];
  _poolSize = size;
  if (self) {
    _taskQueue = [[NSMutableArray alloc] initWithCapacity:8];
    _threadsArray = [[NSMutableArray alloc] initWithCapacity:_poolSize];
    _condition = [[NSCondition alloc] init];
    for (int i = 0; i < _poolSize; i++) {
      NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(main) object:nil];
      [_threadsArray addObject:thread];
      [thread setName:[NSString stringWithFormat:@"Thread%d",i]];
      [thread start];
      [thread release];
    }
  }
  return self;
}


- (void)addTask:(id<BTTask>)newTask {
  [_condition lock];
    [_taskQueue addObject:newTask];
    [newTask setThreadPool:self];
  [_condition signal];
  [_condition unlock];
    dispatch_async(dispatch_get_main_queue(), ^{
      [_delegate didAddTask:newTask];
    });
  
}
- (void)cancelTask:(id<BTTask>)task {
  [_condition lock];
    if ([_taskQueue containsObject:task]) {
      [_taskQueue removeObject:task];
      dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate didCancelTask:task];
      });
    }
  [_condition signal];
  [_condition unlock];
}
- (void)cancelAllTasks {
  [_condition lock];
    [_taskQueue removeAllObjects];
  [_condition signal];
  [_condition unlock];
}

//TODO: 这个Main方法的实现存在的问题是？
- (void)main {
  NSThread *curThread = [NSThread currentThread];
  while (![curThread isCancelled]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
      id<BTTask> task = nil;
      [_condition lock];
        if ([_taskQueue count] > 0) {
          task = [[_taskQueue objectAtIndex:0] retain];
          [_taskQueue removeObjectAtIndex:0];
        } else {
          //NSLog(@"%@ process: wait", [[NSThread currentThread] name]);
          [_condition wait];
        }
      [_condition unlock];
      if (task) {
        if ([task isCanceled] == NO) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate willStartTask:task];
          });
          //NSLog(@"%@ process: Task[%d] start", [[NSThread currentThread] name],task.taskID);
          [task run];
          //NSLog(@"%@ process: Task[%d] end", [[NSThread currentThread] name],task.taskID);
          dispatch_async(dispatch_get_main_queue(), ^{
            [task retain];
            [_delegate didFinishTask:task];
            [task release];
          });
          [task release];
        } else {
          dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate didCancelTask:task];
          });
        }
      }
    }
    @catch (NSException *exception) {
      NSLog(@"exception:%@", exception);
    }
    @finally {
      [pool release];
    }
  }
  NSLog(@"%@ Exit!------",[[NSThread currentThread] name]);
}
@end
