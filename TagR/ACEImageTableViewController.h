//
//  ACEImageTableViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 6/20/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ACEImageTableViewController : UITableViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *useCamera;

@end
