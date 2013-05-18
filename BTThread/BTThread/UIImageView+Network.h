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
 TODO: 在无内存缓存的情况，小图的流畅性要比大图好，需要测试一下到底是IO影响了流畅性，还是大图绘制，将大图在从IO读出转成小图试试
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
