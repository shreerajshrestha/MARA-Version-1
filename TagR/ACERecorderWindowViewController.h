//
//  ACERecorderWindowViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 6/20/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ACERecorderWindowViewController : UIViewController
<UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *saveAsTextField;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UIButton *getLocationDataButton;
@property (weak, nonatomic) IBOutlet UITextField *latitudeLabel;
@property (weak, nonatomic) IBOutlet UITextField *longitudeLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property BOOL gotLocation;

- (IBAction)getLocationDataButtonTapped:(UIButton *)sender;
- (IBAction)saveRecordingButtonTapped:(UIBarButtonItem *)sender;

@end
