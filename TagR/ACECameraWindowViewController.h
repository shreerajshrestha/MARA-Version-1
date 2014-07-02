//
//  ACECameraWindowViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 6/21/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ACECameraWindowViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>

//@property BOOL newMedia;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UITextField *saveAsTextFieldAddImage;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextFieldAddImage;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextFieldAddImage;
@property (weak, nonatomic) IBOutlet UITextField *latitudeLabel;
@property (weak, nonatomic) IBOutlet UITextField *longitudeLabel;

- (IBAction)getLocationDataButtonAddImageTapped:(UIButton *)sender;
- (IBAction)useCameraForImageButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)saveImageButtonTapped:(UIBarButtonItem *)sender;

@end
