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
<UINavigationControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *saveAsTextFieldAddRecording;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextFieldAddRecording;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextFieldAddRecording;
@property (weak, nonatomic) IBOutlet UITextField *latitudeLabel;
@property (weak, nonatomic) IBOutlet UITextField *longitudeLabel;

- (IBAction)getLocationDataButtonAddRecordingTapped:(UIButton *)sender;
- (IBAction)saveRecordingButtonTapped:(UIBarButtonItem *)sender;

@end
