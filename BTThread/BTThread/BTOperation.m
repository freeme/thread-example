//
//  BTOperation.m
//  NSOp
//
//  Created by Gary on 13-4-2.
//  Copyright (c) 2013年 Gary. All rights reserved.
//

#import "BTOperation.h"

@implementation BTOperation


- (BOOL)isConcurrent {
  return NO;
}

- (void)main {
  @try {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (![self isCancelled]) {
      NSLog(@"th:%@-op:%@",[NSThread currentThread],self.name);
    }
    
    [pool release];
  }
  @catch (NSException *exception) {
    
  }
  @finally {
    
  }
}
@end
