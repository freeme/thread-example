//
//  BTThreadPoolViewController.h
//  BTThread
//
//  Created by Gary on 13-4-7.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTThreadPool.h"

@interface BTThreadPoolViewController : UITableViewController<BTThreadPoolDelegate> {
  BTThreadPool* _threadPool;
  NSMutableArray *_items;
}

@end
