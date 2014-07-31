//
//  ACERecorderWindowViewController.h
//  arc
//
//  Created by Shree Raj Shrestha on 6/20/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "ACERecorderViewController.h"

@interface ACERecorderWindowViewController : UIViewController
<AVAudioPlayerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, RecordingStateDelegate, FDWaveformViewDelegate>

@property (strong, nonatomic) IBOutlet FDWaveformView *waveform;
@property (strong, nonatomic) IBOutlet UITextField *saveAsTextField;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UIButton *getLocationDataButton;
@property (strong, nonatomic) IBOutlet UITextField *latitudeLabel;
@property (strong, nonatomic) IBOutlet UITextField *longitudeLabel;

@property (strong, nonatomic) NSURL *tempURL;
@property (strong, nonatomic) NSTimer *timer;

@property BOOL gotLocation;
@property float latitude;
@property float longitude;
@property BOOL initplayer;

- (IBAction)previewTouched:(UITapGestureRecognizer *)sender;
- (IBAction)getLocationDataButtonTapped:(UIButton *)sender;
- (IBAction)saveRecordingButtonTapped:(UIButton *)sender;
- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender;

@end
