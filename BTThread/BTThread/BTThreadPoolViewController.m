//
//  BTThreadPoolViewController.m
//  BTThread
//
//  Created by Gary on 13-4-7.
//  Copyright (c) 2013年 He baochen. All rights reserved.
//

#import "BTThreadPoolViewController.h"

@interface BTThreadPoolViewController ()

@end

@implementation BTThreadPoolViewController

- (id)initWithThreadPool:(id<BTThreadPool>)threadPool {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self) {
    _threadPool = [threadPool retain];
    _threadPool.delegate = self;
    _items = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc {
  _threadPool.delegate = nil;
  [_threadPool release];
  [_items release];
  [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTask)] autorelease];
}

- (void)addTask {
  for (int i = 0; i < 5; i++) {
    BTTask *newTask = [[BTTask alloc] init];
    [_threadPool addTask:newTask];
    [newTask release];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //cell.
  }
    // Configure the cell...
  BTTask *task = [_items objectAtIndex:indexPath.row];
  cell.textLabel.text =  [NSString stringWithFormat:@"Task ID: %d",task.taskID];
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
  BTTask *task = [_items objectAtIndex:indexPath.row];
  [task cancel];
}
#pragma mark - Thread pool delegate
- (void) didAddTask:(id<BTTask>)task {
  [_items addObject:task];
  [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[_items count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
  
}
- (void) willStartTask:(id<BTTask>)task {
  
}
- (void) didFinishTask:(id<BTTask>)task {
  NSInteger row = [_items indexOfObject:task];
  //[self.tableView reloadData];
  [_items removeObject:task];
  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
  
}
- (void) didCancelTask:(id<BTTask>)task {
  NSInteger row = [_items indexOfObject:task];
  //[self.tableView reloadData];
  [_items removeObject:task];
  [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

@end
