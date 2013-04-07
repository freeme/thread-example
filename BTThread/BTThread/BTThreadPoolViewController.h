//
//  BTThreadPoolViewController.h
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTThreadPool.h"

@interface BTThreadPoolViewController : UIViewController {
  BTThreadPool *_threadPool;
}

- (IBAction)addTask:(id)sender;

@end
