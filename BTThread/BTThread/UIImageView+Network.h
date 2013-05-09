//
//  UIImageView+Network.h
//  BTThread
//
//  Created by Gary on 13-5-6.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTURLRequestOperation.h"
typedef NS_OPTIONS(NSUInteger, UIImageViewRequestMode) {
  UIImageViewRequestModeNone        = 0,
  UIImageViewRequestModeAutoStop        = 1 << 0,
  UIImageViewRequestModeAutoReload      = 1 << 1,
};
@interface UIImageView (Network) <BTURLRequestDelegate>
- (void)setImageWithURL:(NSURL *)url;
- (void)cancelImageRequestOperation;
- (void)reloadImageRequestIfNeed;
@end
