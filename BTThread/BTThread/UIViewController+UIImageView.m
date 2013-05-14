//
//  UIViewController+UIImageView.m
//  BTThread
//
//  Created by Gary on 13-5-6.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "UIViewController+UIImageView.h"
#import <objc/runtime.h>

@interface UIViewController(_UIImageView)
- (void)reloadImageRequestIfNeed;
- (void)cancelImageRequestIfNeed;
@end

@implementation UIViewController (UIImageView)

+ (void)initialize {
  Class klass = [UIViewController class];
  method_exchangeImplementations(class_getInstanceMethod(klass,@selector(viewWillAppear:)),class_getInstanceMethod(klass, @selector(__replacedViewWillAppear:)));
  method_exchangeImplementations(class_getInstanceMethod(klass,@selector(viewWillDisappear:)),class_getInstanceMethod(klass, @selector(__replacedViewWillDisappear:)));
}

- (void)__replacedViewWillAppear:(BOOL)animated {
  NSLog(@"replaced %s ",__FUNCTION__);
  [self reloadImageRequestIfNeed];
}

- (void)__replacedViewWillDisappear:(BOOL)animated {
  NSLog(@"replaced %s ",__FUNCTION__);
  [self cancelImageRequestIfNeed];
}


- (void)reloadImageRequestIfNeed {
  [self findImageViewInParentView:self.view andPerformSelector:@selector(reloadImageRequestIfNeed)];
}

- (void)cancelImageRequestIfNeed {
  [self findImageViewInParentView:self.view andPerformSelector:@selector(cancelImageRequestIfNeed)];
}

- (void)findImageViewInParentView:(UIView*)parentView andPerformSelector:(SEL)selector {
  Class imageClass = [UIImageView class];
  for (UIView *view in parentView.subviews) {
    if ([view isKindOfClass:imageClass] && [view respondsToSelector:selector]) {
      [view performSelector:selector];
    }
    if ([view.subviews count]) {
      [self findImageViewInParentView:view andPerformSelector:selector];
    }
  }
}
@end
