//
//  BTRunLoopThreadPool.m
//  BTThread
//
//  Created by Gary on 13-4-8.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTRunLoopThreadPool.h"

@interface BTRunLoopThreadPool() 
- (void)runLoopPerform;
- (void)notifyThreads;
- (void)runLoopObserverCallback: (CFRunLoopActivity) activity;
@end

@implementation BTRunLoopThreadPool


void BTRunLoopSourcePerformRoutine (void *info) {
  BTRunLoopThreadPool* obj = (BTRunLoopThreadPool*)info;
  
  [obj runLoopPerform];
  __block NSString *threadName = [[NSThread currentThread] name];
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSLog(@"%@-%s",threadName,__FUNCTION__);
  });
  
}

void BTRunLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
  //NSLog(@"%@: BTRunLoopObserverCallBack CFRunLoopActivity:%lu",[[NSThread currentThread] name], activity);
  BTRunLoopThreadPool* obj = (BTRunLoopThreadPool*)info;
  [obj runLoopObserverCallback:activity];
}

- (void)dealloc {
  [_idleThreads release];
  [super dealloc];
}

- (id) initWithPoolSize:(int)size {
  self =[super init];
  _poolSize = size;
  _idleThreads = [[NSMutableSet alloc] initWithCapacity:size];
  CFRunLoopSourceContext sourceContext = {0, self, NULL, NULL, NULL, NULL, NULL,
    NULL,NULL,&BTRunLoopSourcePerformRoutine};
  _runLoopSource = CFRunLoopSourceCreate(NULL, 0, &sourceContext);
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

- (void)addTask:(id<BTTask>)newTask {
  [super addTask:newTask];
  [self notifyThreads];
}

- (void)cancelTask:(id<BTTask>)task {
  [super cancelTask:task];
  //[self notifyThreads];
}

- (void)notifyThreads {
  //NSLog(@"%s %@ >>>>>>>>>>>>>>",__FUNCTION__,[[NSThread currentThread] name]);
  
//  while (YES) {
//    @synchronized(_taskQueue) {
//      if ([_taskQueue count]) {
//        CFRunLoopSourceSignal(_runLoopSource);
//        
//      } else {
//        break;
//      }
//    }
//  }
  
  //CFRunLoopSourceSignal(_runLoopSource);
  
  NSRunLoop *runLoop = nil;
  @synchronized (_idleThreads){
    //NSLog(@"%s %@ >>>>>>>>>>>>>>[_idleThreads count]:%d",__FUNCTION__,[[NSThread currentThread] name],[_idleThreads count]);
    if ([_idleThreads count] > 0) {
      runLoop = [_idleThreads anyObject];
      [_idleThreads removeObject:runLoop];
      CFRunLoopSourceSignal(_runLoopSource);
      CFRunLoopWakeUp([runLoop getCFRunLoop]);
    }
  }
//  if (runLoop) {
//    CFRunLoopSourceSignal(_runLoopSource);
//    CFRunLoopWakeUp([runLoop getCFRunLoop]);
//  }
  //@synchronized(_idleThreads){
//  for (NSRunLoop *runLoop in _idleThreads) {
//    if (CFRunLoopIsWaiting([runLoop getCFRunLoop])) {
//      CFRunLoopSourceSignal(_runLoopSource);
//      CFRunLoopWakeUp([runLoop getCFRunLoop]);
////    dispatch_async(dispatch_get_global_queue(0, 0), ^{
////      NSLog(@"%s",__FUNCTION__);
////    });
//    }
//  }
  //}

//  for (NSThread *thread in _threadsArray) {
//    [self performSelector:@selector(wakeUpThread) onThread:thread withObject:nil waitUntilDone:NO];
//  }
}

- (void)notifyThreadsIfNeed {
  @synchronized(_taskQueue) {
    if ([_taskQueue count] > 0) {
      [self notifyThreads];
    }
  }
}

- (void) wakeUpThread {
  //NSLog(@"%s %@ start",__FUNCTION__,[[NSThread currentThread] name]);
//  if (CFRunLoopIsWaiting(CFRunLoopGetCurrent())) {
//    CFRunLoopWakeUp(CFRunLoopGetCurrent());
//  }
 // NSThread *th = [NSThread currentThread];
//  BOOL isExecuting = [th isExecuting];
  //NSLog(@"th:%@ isExecuting = %d", [th name],isExecuting);
  //if (!isExecuting) {
//    CFRunLoopWakeUp(CFRunLoopGetCurrent());
  //}
  
  //NSLog(@"%s %@ -------------",__FUNCTION__,[[NSThread currentThread] name]);

}

- (void)main {
  //NSLog(@"%s %@ -------------",__FUNCTION__,[[NSThread currentThread] name]);
  NSThread *curThread = [NSThread currentThread];
  NSRunLoop *currentRunLoop = [NSRunLoop currentRunLoop];

  CFRunLoopAddSource([currentRunLoop getCFRunLoop], _runLoopSource, kCFRunLoopDefaultMode);
  
  CFRunLoopObserverContext observerContext = {0, self, NULL, NULL, NULL};
  CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,
                                                          kCFRunLoopBeforeWaiting|kCFRunLoopAfterWaiting, YES, 0, &BTRunLoopObserverCallBack, &observerContext);
  
  
  if (observer) {
    CFRunLoopAddObserver([currentRunLoop getCFRunLoop], observer, kCFRunLoopDefaultMode);
    //[_idleThreads addObject:currentRunLoop];
  }
//  [_idleThreads addObject:currentRunLoop];
  while (![curThread isCancelled]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
      NSLog(@"CFRunLoopRun");
      //CFRunLoopRun();
      [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    @catch (NSException *exception) {
      NSLog(@"exception:%@", exception);
    }
    @finally {
      [pool release];
    }
  }
  CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopDefaultMode);
  CFRelease(_runLoopSource);
  _runLoopSource = NULL;
  NSLog(@"%@ Exit!------",[[NSThread currentThread] name]);
}

- (void)runLoopPerform {
  //NSLog(@"%@ runLoopPerform", [[NSThread currentThread] name]);
  
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
      //NSLog(@"%@ process: Task[%d] start", [[NSThread currentThread] name],task.taskID);
      [task run];
      //NSLog(@"%@ process: Task[%d] end", [[NSThread currentThread] name],task.taskID);
      
      dispatch_async(dispatch_get_main_queue(), ^{
        [task retain];
        [_delegate didFinishTask:task];
        [task release];
      });
      [task release];
      //[self performSelectorOnMainThread:@selector(notifyThreadsIfNeed) withObject:nil waitUntilDone:NO];
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        [_delegate didCancelTask:task];
      });
    }
  } 
}

- (void)runLoopObserverCallback: (CFRunLoopActivity) activity {
  
  @synchronized (_idleThreads){
    if (activity == kCFRunLoopBeforeWaiting) {
      [_idleThreads addObject:[NSRunLoop currentRunLoop]];
    } else if (activity == kCFRunLoopAfterWaiting) {
      //[_idleThreads removeObject:[NSRunLoop currentRunLoop]];
    }
  }
  //NSLog(@"%@,activity:%lu _idleThreads count:%d",[[NSThread currentThread] name],activity,[_idleThreads count]);
}
@end
