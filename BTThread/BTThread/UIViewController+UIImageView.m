//
//  UIViewController+UIImageView.m
//  BTThread
//
//  Created by Gary on 13-5-6.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "UIViewController+UIImageView.h"

@interface UIViewController(_UIImageView)
- (void)reloadImageRequestIfNeed;
- (void)cancelAllImageRequest;
@end

@implementation UIViewController (UIImageView)

//- (void)viewWillAppear:(BOOL)animated {
//  [self reloadImageRequestIfNeed];
//}
//
//- (void)viewDidDisappear:(BOOL)animated {
//  [self cancelImageRequestIfNeed];
//}

- (void)reloadImageViewIfNeed {
  [self findImageViewInParentView:self.view andPerformSelector:@selector(reloadImageRequestIfNeed)];
}

- (void)cancelImageRequestIfNeed {
  [self findImageViewInParentView:self.view andPerformSelector:@selector(cancelImageRequestOperation)];
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
