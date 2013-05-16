//
//  UIImageView+Network.h
//  BTThread
//
//  Created by Gary on 13-5-6.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTURLRequestOperation.h"

/**
 TODO: [[UIScreen mainScreen] scale]
 
 */

@interface UIImageView (Network) <BTURLRequestDelegate>
- (void)setImageWithURL:(NSURL *)url;
- (void)cancelImageRequestOperation;
- (void)reloadImageRequestIfNeed;
- (void)cancelImageRequestIfNeed;
//Cancel request when "view will disappear"
@property(nonatomic) BOOL isAutoCancelRequest;

//Auto send request when "view did appear"
@property(nonatomic) BOOL isAutoReloadRequest;
@end
