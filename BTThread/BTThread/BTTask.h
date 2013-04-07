//
//  BTTask.h
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BTThreadPool;
@protocol BTTask <NSObject>
- (void)cancel;
- (BOOL)isCanceled;
- (void)run;
@property (nonatomic, readonly) NSInteger taskID;
@property (nonatomic, readonly)  BTThreadPool *threadPool;
@end

@interface BTTask : NSObject<BTTask> {
  volatile BOOL _canceled;
  NSInteger _taskID;
  BTThreadPool *_threadPool;
}

@end
