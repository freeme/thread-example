//
//  BTRootViewController.m
//  BTThread
//
//  Created by He baochen on 13-3-28.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTRootViewController.h"
#import "BTThreadPoolViewController.h"
#import "BTOperationViewController.h"
#import "BTThreadPool.h"
#import "BTLockThreadPool.h"
#import "BTRunLoopThreadPool.h"
#import "UIImageView+Network.h"

@interface BTRootViewController ()

@end

@implementation BTRootViewController

- (void)dealloc {
  [_threadExamples release];
  
  [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
      self.title = @"BTThread Example";
      _threadExamples = [[NSArray alloc] initWithObjects:@"BTThreadPool",@"BTLockThreadPool",@"BTRunLoopThreadPool", nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  if (section == 0) {
    return [_threadExamples count];
  } else {
    return 1;
  }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"];
    //NSLog(@"imagePath = %@", imagePath);
//    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"Default" withExtension:@"png"];
////    NSLog(@"imageURL = %@", imageURL);
////    NSLog(@"imageURL relativePath = %@", [imageURL relativePath]);
////    NSLog(@"imageURL absoluteString = %@", [imageURL absoluteString]);
//    [cell.imageView setImageWithURL:imageURL];
    cell.imageView.clipsToBounds = YES;
    cell.imageView.contentMode = UIViewContentModeCenter;
//    cell.imageView.image = [UIImage imageNamed:@"Default.png"];
  }
    // Configure the cell...
  if (indexPath.section == 0) {
      cell.textLabel.text = [_threadExamples objectAtIndex:indexPath.row];
  } else {
    cell.textLabel.text = @"Concurrent Operation";
  }
  NSURL *imageURL = [[NSBundle mainBundle] URLForResource:@"icon2" withExtension:@"png"];
//  [cell.imageView setImageWithURL:imageURL];
  UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 0, 44, 44)];
  [cell.contentView addSubview:imageView];
  [imageView setImageWithURL:imageURL];
  [imageView release];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    id<BTThreadPool> threadPool = nil;
    NSString *className = [_threadExamples objectAtIndex:indexPath.row];
    Class cls = NSClassFromString(className);
    threadPool = [[cls alloc] initWithPoolSize:2];
    BTThreadPoolViewController *poolController = [[BTThreadPoolViewController alloc] initWithThreadPool:threadPool];
    [threadPool release];
    [self.navigationController pushViewController:poolController animated:YES];
    [poolController release];
  } else if (indexPath.section == 1) {
    BTOperationViewController *viewController = [[BTOperationViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
  }

}

@end
