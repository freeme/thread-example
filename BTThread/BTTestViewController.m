//
//  BTTestViewController.m
//  BTThread
//
//  Created by Gary on 13-6-25.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTTestViewController.h"

@interface BTTestViewController () {
  int test1;

  UILabel *label1;
  UILabel *label2;
  
  NSLock *lock;
  
  NSRecursiveLock *recursiveLock;
  
}

@end

@implementation BTTestViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
      lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  bt1.frame = CGRectMake(10, 10, 100, 30);
  [bt1 setTitle:@"startTest1" forState:UIControlStateNormal];
  [bt1 addTarget:self action:@selector(startTest1) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:bt1];
  
  label1 = [[UILabel alloc] initWithFrame:CGRectMake(120, 10, 100, 30)];
  [self.view addSubview:label1];
  
  label2 = [[UILabel alloc] initWithFrame:CGRectMake(230, 10, 100, 30)];
  [self.view addSubview:label2];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startTest1 {
  test1 = 0;
  //NSLog(@"test1 = %d", test1);
  [NSThread detachNewThreadSelector:@selector(testCase1) toTarget:self withObject:nil];
  [NSThread detachNewThreadSelector:@selector(testCase1) toTarget:self withObject:nil];
  [NSThread detachNewThreadSelector:@selector(testCase1) toTarget:self withObject:nil];
  [NSThread detachNewThreadSelector:@selector(testCase1) toTarget:self withObject:nil];
  [NSThread detachNewThreadSelector:@selector(testCase1) toTarget:self withObject:nil];
  [NSThread detachNewThreadSelector:@selector(testCase1) toTarget:self withObject:nil];
  [NSThread detachNewThreadSelector:@selector(testCase1) toTarget:self withObject:nil];
  [NSThread detachNewThreadSelector:@selector(testCase1) toTarget:self withObject:nil];
  //int temp = test1;
  label1.text = [NSString stringWithFormat:@"label1 = %d",test1];
  //NSLog(@"test1 in main thread = %d", test1);
  label2.text = [NSString stringWithFormat:@"label2 = %d",test1];
}

//- (void)testCase1 {
//  if (test1==5) {
//    
//  
//  NSLog(@"test1 = %d", test1);
//}
//  test1++;
//  //NSLog(@"test1 = %d", test1);
//}


- (void)testCase1 {
  //NSLog(@"test1 = %d", test1);
  [lock lock];
  test1++;
  [self testCase11];
  [lock unlock];
  //NSLog(@"test1 = %d", test1);
}

- (void)testCase11 {
  [lock lock];
  test1++;
  [lock unlock];
}




/*
//- (void)testCase1 {
//  //NSLog(@"test1 = %d", test1);
//  @synchronized(self) {
//    test1++;
//    [self testCase11];
//  }
//  //NSLog(@"test1 = %d", test1);
//}
//
//- (void)testCase11 {
//  @synchronized(self) {
//    test1++;
//  }
//}
*/

@end
