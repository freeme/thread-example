//
//  BTOperationViewController.m
//  BTThread
//
//  Created by Gary on 13-4-30.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTOperationViewController.h"
#import "BTConcurrentOperation.h"
#import "UIImageView+Network.h"
#import "BTCache.h"
@interface BTOperationViewController ()

@end

@implementation BTOperationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
      _users = [[NSMutableArray alloc] initWithCapacity:10];
      
      NSURL *url = [[NSBundle mainBundle] URLForResource:@"global0" withExtension:@"json"];
      NSData *data = [NSData dataWithContentsOfURL:url];
      id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:NULL];
      NSArray *postsFromResponse = [responseJSON valueForKeyPath:@"data"];
      
      for (NSDictionary *attributes in postsFromResponse) {
//        _users u = [attributes valueForKeyPath:@"user.avatar_image.url"];
//        NSString *coverURL = [attributes valueForKeyPath:@"user.cover_image.url"];
        [_users addObject:[attributes valueForKeyPath:@"user"]];
        //[_users addObject:coverURL];
      }
      for (NSDictionary *attributes in postsFromResponse) {
        //        _users u = [attributes valueForKeyPath:@"user.avatar_image.url"];
        //        NSString *coverURL = [attributes valueForKeyPath:@"user.cover_image.url"];
        [_users addObject:[attributes valueForKeyPath:@"user"]];
        //[_users addObject:coverURL];
      }
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Uncomment the following line to preserve selection between presentations.
  self.clearsSelectionOnViewWillAppear = YES;
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(clearAndRest)] autorelease];
}

- (void)clearAndRest {
  [[BTCache sharedCache] clearAll];
  for (NSDictionary *userDict in _users) {
    NSURL *url = [NSURL URLWithString:[userDict valueForKeyPath:@"cover_image.url"]];
    NSLog(@"url:%@",url);
    [[BTCache sharedCache] imageForURL:url completionBlock:NULL];
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [_users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    {
      UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(200, 0, 44, 44)];
      [cell addSubview:imageView];
      imageView.tag = 100;
      [imageView release];
    }
    {
      UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(260, 0, 44, 44)];
      [cell addSubview:imageView];
      imageView.tag = 200;
      [imageView release];
    }
  }
  cell.textLabel.text = [[_users objectAtIndex:indexPath.row] valueForKeyPath:@"username"];
  {
//    UIImageView *imageView = (UIImageView*)[cell viewWithTag:100];
//    [imageView setImageWithURL:[NSURL URLWithString:[[_users objectAtIndex:indexPath.row] valueForKeyPath:@"avatar_image.url"]]];
  }
  {
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:200];
    [imageView setImageWithURL:[NSURL URLWithString:[[_users objectAtIndex:indexPath.row] valueForKeyPath:@"cover_image.url"]]];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
