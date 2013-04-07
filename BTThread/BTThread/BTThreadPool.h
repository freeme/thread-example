//
//  BTThreadPool.h
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTTask.h"
#define BTThreadPoolDefaultSize 2


@interface BTThreadPool : NSObject {
  int _poolSize;
  NSMutableArray *_threadsArray;
  NSMutableArray *_taskQueue;
}
- (id) initWithPoolSize:(int)size;
- (void)addTask:(id<BTTask>)newTask;
- (void)cancelTask:(id<BTTask>)task;
- (void)cancelAllTasks;
@end
