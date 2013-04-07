//
//  BTTask.h
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BTTask <NSObject>
- (void)cancel;
- (BOOL)isCanceled;
- (void)run;

@end

@interface BTTask : NSObject<BTTask> {
  BOOL _canceled;
}

@end
