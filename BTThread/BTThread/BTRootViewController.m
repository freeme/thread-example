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
#import "UIImageView+Network.h"
#import "BTTestViewController.h"

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
      _threadExamples = [[NSArray alloc] initWithObjects:@"BTThreadPool",@"BTLockThreadPool", nil];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
  if (section == 0||section == 1) {
    return 1;

  } else {
    return [_threadExamples count];
  }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
    // Configure the cell...
  if (indexPath.section == 0) {
    cell.textLabel.text = @"Test View";
  } else if (indexPath.section == 1) {
    cell.textLabel.text = @"Concurrent Operation";
  } else {
     cell.textLabel.text = [_threadExamples objectAtIndex:indexPath.row];
  }
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
    BTTestViewController *controller = [[BTTestViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
    
  }  else if (indexPath.section == 1) {
    BTOperationViewController *controller = [[BTOperationViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];
  } else if (indexPath.section == 2) {
//    BTOperationViewController *viewController = [[BTOperationViewController alloc] initWithStyle:UITableViewStylePlain];
//    [self.navigationController pushViewController:viewController animated:YES];
//    [viewController release];
    id<BTThreadPool> threadPool = nil;
    NSString *className = [_threadExamples objectAtIndex:indexPath.row];
    Class cls = NSClassFromString(className);
    threadPool = [[cls alloc] initWithPoolSize:2];
    BTThreadPoolViewController *poolController = [[BTThreadPoolViewController alloc] initWithThreadPool:threadPool];
    [threadPool release];
    [self.navigationController pushViewController:poolController animated:YES];
    [poolController release];
  }

}

@end
