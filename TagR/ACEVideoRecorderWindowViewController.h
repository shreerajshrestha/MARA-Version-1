//
//  ACEVideoRecorderWindowViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 6/26/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AppDelegate.h"

@interface ACEVideoRecorderWindowViewController : UIViewController
<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *saveAsTextField;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UIButton *getLocationDataButton;
@property (weak, nonatomic) IBOutlet UITextField *latitudeLabel;
@property (weak, nonatomic) IBOutlet UITextField *longitudeLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

//@property (strong, nonatomic) IBOutlet UIImageView *thumbImage;
//@property (strong,nonatomic) MPMoviePlayerController *videoController;
@property (strong,nonatomic) NSURL *videoURL;
@property BOOL gotLocation;

- (IBAction)getLocationDataButtonTapped:(UIButton *)sender;
- (IBAction)useCameraButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)saveVideoButtonTapped:(UIBarButtonItem *)sender;

@end
