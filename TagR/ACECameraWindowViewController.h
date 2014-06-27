//
//  ACECameraWindowViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 6/21/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ACECameraWindowViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

//@property BOOL newMedia;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

- (IBAction)useCamera:(UIBarButtonItem *)sender;
- (IBAction)saveImageButton:(UIBarButtonItem *)sender;


@end
