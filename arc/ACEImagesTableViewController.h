//
//  ACEImagesTableViewController.h
//  arc
//
//  Created by Shree Raj Shrestha on 7/7/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ACEImagesTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *mediaDetails;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) NSFetchRequest *searchFetchRequest;

- (void)filterContentForSearchText:(NSString*)searchText scope:(int)scope;

@end