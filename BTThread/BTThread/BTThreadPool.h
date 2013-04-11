//
//  BTThreadPool.h
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTTask.h"
#define BTThreadPoolDefaultSize 3
@protocol BTThreadPoolDelegate<NSObject>
- (void) didAddTask:(id<BTTask>)task;
- (void) willStartTask:(id<BTTask>)task;
- (void) didFinishTask:(id<BTTask>)task;
- (void) didCancelTask:(id<BTTask>)task;
@end

@protocol BTThreadPool<NSObject>
@property (nonatomic,assign) id<BTThreadPoolDelegate> delegate;
- (id) initWithPoolSize:(int)size;
- (void)addTask:(id<BTTask>)newTask;
- (void)cancelTask:(id<BTTask>)task;
@end

@interface BTThreadPool : NSObject<BTThreadPool> {
  int _poolSize;
  NSMutableArray *_threadsArray;
  NSMutableArray *_taskQueue;
  id<BTThreadPoolDelegate> _delegate;
}

@end
