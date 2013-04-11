//
//  BTLockThreadPool.h
//  BTThread
//
//  Created by Gary on 13-4-11.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTThreadPool.h"

@interface BTLockThreadPool : BTThreadPool {
  NSCondition  *_condition;
}

@end
