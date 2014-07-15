//
//  ACEImagesTableViewController.m
//  TagR
//
//  Created by Shree Raj Shrestha on 7/7/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEImagesTableViewController.h"

@interface ACEImagesTableViewController ()

@end

@implementation ACEImagesTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ImageDB"];
    self.mediaDetails = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    [self.tableView reloadData];
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
    return self.mediaDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ImageCell"
                                                                  forIndexPath:indexPath];
    
    // Configure the cell...
    NSManagedObject *mediaDetail = [self.mediaDetails objectAtIndex:indexPath.row];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathComponent = [NSString stringWithFormat:@"/MyImages/%@", [mediaDetail valueForKey:@"fileName"]];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:pathComponent];
    cell.textLabel.text = [mediaDetail valueForKey:@"name"];
    cell.detailTextLabel.text = [mediaDetail valueForKey:@"tags"];
    cell.imageView.image = [UIImage imageWithContentsOfFile:filePath];
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Delete file from the documents directory
    NSManagedObject *mediaDetail = [self.mediaDetails objectAtIndex:indexPath.row];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathComponent = [NSString stringWithFormat:@"/MyImages/%@", [mediaDetail valueForKey:@"fileName"]];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:pathComponent];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    
    // Delete object from database
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    [context deleteObject:[self.mediaDetails objectAtIndex:indexPath.row]];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Cannot delete %@ %@", error, [error localizedDescription]);
        return;
    }
    
    // Remove device from table view
    [self.mediaDetails removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
