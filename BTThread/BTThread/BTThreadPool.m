//
//  BTThreadPool.m
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTThreadPool.h"


@interface BTTask(BTThreadPool)

- (void)setThreadPool:(BTThreadPool*)threadPool;

@end


@implementation BTTask(BTThreadPool)

- (void)setThreadPool:(BTThreadPool*)threadPool {
  _threadPool = threadPool;
}

@end

@interface BTThread : NSThread

@end

@interface BTThreadPool()

- (void) cancelThreads;

@end

@implementation BTThreadPool
@synthesize delegate = _delegate;
- (void)dealloc {
  [self cancelAllTasks];
  [self cancelThreads];
  [_taskQueue release];
  [_threadsArray release];
  _delegate = nil;
  [super dealloc];
}

- (id) init {
  return [self initWithPoolSize:BTThreadPoolDefaultSize];
}

- (id) initWithPoolSize:(int)size {
  self =[super init];
  _poolSize = size;
  if (self) {
    _taskQueue = [[NSMutableArray alloc] initWithCapacity:8];
    _threadsArray = [[NSMutableArray alloc] initWithCapacity:_poolSize];
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

- (void) cancelThreads {
  for (NSThread *thread in _threadsArray) {
    [thread cancel];
  }
}
- (void)addTask:(id<BTTask>)newTask {
  @synchronized(_taskQueue) {
    [_taskQueue addObject:newTask];
    [newTask setThreadPool:self];
    dispatch_async(dispatch_get_main_queue(), ^{
      [_delegate didAddTask:newTask];
    });
  }
}
- (void)cancelTask:(id<BTTask>)task {
  @synchronized(_taskQueue) {
    if ([_taskQueue containsObject:task]) {
      [_taskQueue removeObject:task];
      dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate didCancelTask:task];
      });
    }
  }
}
- (void)cancelAllTasks {
  @synchronized(_taskQueue) {
    [_taskQueue removeAllObjects];
  }
}

#pragma mark Thread Method

- (void)main {
  
  
  NSThread *curThread = [NSThread currentThread];
  while (![curThread isCancelled]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    id<BTTask> task = nil;
    @synchronized(_taskQueue) {
      if ([_taskQueue count] > 0) {
        task = [[_taskQueue objectAtIndex:0] retain];
        [_taskQueue removeObjectAtIndex:0];
      }
    }
    if (task) {
      if ([task isCanceled] == NO) {
        dispatch_async(dispatch_get_main_queue(), ^{
          [_delegate willStartTask:task];
        });
        NSLog(@"%@ process: Task[%d] start", [[NSThread currentThread] name],task.taskID);
        [task run];
        NSLog(@"%@ process: Task[%d] end", [[NSThread currentThread] name],task.taskID);
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
    } else {
      [NSThread sleepForTimeInterval:0.2];
    }

    [pool release];
  }
  
}

@end




