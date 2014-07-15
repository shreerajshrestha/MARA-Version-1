//
//  ACEImagesTableViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 7/7/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ACEImagesTableViewController : UITableViewController
<UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong) NSMutableArray *mediaDetails;

@end