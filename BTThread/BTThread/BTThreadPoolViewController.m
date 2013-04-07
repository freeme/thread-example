//
//  BTThreadPoolViewController.m
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTThreadPoolViewController.h"
#import "BTTask.h"
@interface BTThreadPoolViewController ()

@end

@implementation BTThreadPoolViewController

- (void)dealloc {
  [_threadPool cancelAllTasks];
  [_threadPool release];
  [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
      _threadPool = [[BTThreadPool alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addTask:(id)sender {
  for (int i = 0; i<25;i++) {
    BTTask *task = [[BTTask alloc] init];
    [_threadPool addTask:task];
    [task release];
  }
}

@end
