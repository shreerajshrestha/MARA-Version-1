//
//  ACEVideoRecorderWindowViewController.h
//  arc
//
//  Created by Shree Raj Shrestha on 6/26/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AppDelegate.h"

@interface ACEVideoRecorderWindowViewController : UIViewController
<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIView *preview;
@property (strong, nonatomic) IBOutlet UITextField *saveAsTextField;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UIButton *getLocationDataButton;
@property (strong, nonatomic) IBOutlet UITextField *latitudeLabel;
@property (strong, nonatomic) IBOutlet UITextField *longitudeLabel;

@property (strong, nonatomic) NSURL *tempURL;

@property BOOL gotLocation;
@property float latitude;
@property float longitude;

- (IBAction)getLocationDataButtonTapped:(UIButton *)sender;
- (IBAction)useCameraButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)saveVideoButtonTapped:(UIButton *)sender;
- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender;


@end
