//
//  BTRunLoopThreadPool.h
//  BTThread
//
//  Created by Gary on 13-4-8.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTThreadPool.h"

@interface BTRunLoopThreadPool : BTThreadPool {
  CFRunLoopSourceRef _runLoopSource;
  NSMutableSet *_idleThreads;
}

@end
