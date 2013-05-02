//
//  BTConcurrentOperation.m
//  BTThread
//
//  Created by Gary on 13-4-2.
//  Copyright (c) 2013年 Gary. All rights reserved.
//

#import "BTConcurrentOperation.h"

/*
KVO
isCancelled
isConcurrent
isExecuting
isFinished
isReady
dependencies
queuePriority
completionBlock
 */

typedef NS_ENUM(unsigned short, BTOperationState){
  BTOperationReadyState       = 1,
  BTOperationExecutingState   = 2,
  BTOperationFinishedState    = 3,
};

static inline NSString * BTKeyPathFromOperationState(BTOperationState state) {
  switch (state) {
    case BTOperationReadyState:
      return @"isReady";
    case BTOperationExecutingState:
      return @"isExecuting";
    case BTOperationFinishedState:
      return @"isFinished";
    default:
      return @"state";
  }
}

static inline BOOL BTStateTransitionIsValid(BTOperationState fromState, BTOperationState toState, BOOL isCancelled) {
  switch (fromState) {
    case BTOperationReadyState:
      switch (toState) {
        case BTOperationExecutingState:
          return YES;
        case BTOperationFinishedState:
          return isCancelled;
        default:
          return NO;
      }
    case BTOperationExecutingState:
      switch (toState) {
        case BTOperationFinishedState:
          return YES;
        default:
          return NO;
      }
    case BTOperationFinishedState:
      return NO;
    default:
      return YES;
  }
}

@interface BTConcurrentOperation()
@property (nonatomic) BTOperationState state;
@property (nonatomic) NSRecursiveLock *lock;
@property (nonatomic, assign, getter = isCancelled) BOOL cancelled;
@end

@implementation BTConcurrentOperation
+ (void) internalThreadEntryPoint {
  do {
    @autoreleasepool {
      [[NSRunLoop currentRunLoop] run];
    }
  } while (YES);
}

+ (NSThread *)internalThread {
  static NSThread *_internalThread = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _internalThread = [[NSThread alloc] initWithTarget:self selector:@selector(internalThreadEntryPoint) object:nil];
    [_internalThread setName:@"Internal Thread"];
    [_internalThread start];
  });
  return _internalThread;
}

- (void)dealloc {
  self.name = nil;
  self.runLoopModes = nil;
  self.lock = nil;
  [super dealloc];
}

- (id) init {
  self = [super init];
  if (self) {
    self.lock = [[NSRecursiveLock alloc] init];
    self.state = BTOperationReadyState;
    self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
  }
  return self;
}

- (void)setState:(BTOperationState)state {
  if (!BTStateTransitionIsValid(self.state, state, [self isCancelled])) {
    return;
  }
  
  [self.lock lock];
  NSString *oldStateKey = BTKeyPathFromOperationState(self.state);
  NSString *newStateKey = BTKeyPathFromOperationState(state);
  
  [self willChangeValueForKey:newStateKey];
  [self willChangeValueForKey:oldStateKey];
  _state = state;
  [self didChangeValueForKey:oldStateKey];
  [self didChangeValueForKey:newStateKey];
  [self.lock unlock];
}

#pragma mark - NSOperation

- (BOOL)isReady {
  return self.state == BTOperationReadyState && [super isReady];
}

- (BOOL)isExecuting {
  return self.state == BTOperationExecutingState;
}

- (BOOL)isFinished {
  return self.state == BTOperationFinishedState;
}

- (BOOL)isConcurrent {
  return YES;
}

- (void)start {
  NSLog(@"start >> th:%@-op:%@",[NSThread currentThread],self.name);
  [self.lock lock];
  if ([self isCancelled]) {
    [self finish];
    return;
  } else if ([self isReady]) {
    self.state = BTOperationExecutingState;
    [self performSelector:@selector(main) onThread:[[self class] internalThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
  }
  [self.lock unlock];
}

- (void)main {
  [self.lock lock];
  @autoreleasepool {
    NSLog(@"main >> th:%@-op:%@",[NSThread currentThread],self.name);
    if (![self isCancelled]) {
      [self concurrentExecution];
    }
  }
  [self.lock unlock];
  dispatch_async(dispatch_get_main_queue(), ^{
      [self notifyAfterExecutionOnMainThread];
  });
  if ([self isCancelled]) {
    [self finish];
  }
  
}

/**
 Subclass should overwrite this method
 */
- (void)concurrentExecution {
  [self performSelectorInBackground:@selector(testRunOnOthreThread) withObject:nil];
}

/*
 模拟异步操作
 */
- (void)testRunOnOthreThread {
  //执行时查检是否已经被取消
  if (![self isCancelled]) {
    //模拟异步操作耗时
    [NSThread sleepForTimeInterval:1];
  }
  [self performSelector:@selector(finish) onThread:[[self class] internalThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
}

- (void)finish {
  self.state = BTOperationFinishedState;
  
  dispatch_async(dispatch_get_main_queue(), ^{
//    [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidFinishNotification object:self];
    [self notifyFinishExecutionOnMainThread];
  });
}

- (void)cancel {
  [self.lock lock];
  if (![self isFinished] && ![self isCancelled]) {
    [self willChangeValueForKey:@"isCancelled"];
    _cancelled = YES;
    [super cancel];
    [self didChangeValueForKey:@"isCancelled"];
    
    // Cancel the connection on the thread it runs on to prevent race conditions
    [self performSelector:@selector(cancelConcurrentExecution) onThread:[[self class] internalThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
  }
  [self.lock unlock];
}
/**
 Subclass should overwrite this method
 */
- (void)cancelConcurrentExecution {
  NSLog(@"cancelConcurrentExecution >> th:%@-op:%@",[NSThread currentThread],self.name);
}

#pragma mark -
#pragma mark Notify the execution on main thread
- (void)notifyAfterExecutionOnMainThread {
// [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:self];
}

- (void)notifyFinishExecutionOnMainThread {
  // [[NSNotificationCenter defaultCenter] postNotificationName:AFNetworkingOperationDidStartNotification object:self];
      NSLog(@"finish >> th:%@-op:%@",[NSThread currentThread],self.name);
}

@end
