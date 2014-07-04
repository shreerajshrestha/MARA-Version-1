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

@interface ACEVideoRecorderWindowViewController : UIViewController
<UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate>

//@property (strong, nonatomic) IBOutlet UIImageView *thumbImage;

@property (strong,nonatomic) NSURL *videoURL;
@property (strong,nonatomic) MPMoviePlayerController *videoController;
@property (strong, nonatomic) IBOutlet UITextField *saveAsTextFieldAddVideo;
@property (strong, nonatomic) IBOutlet UITextField *tagsTextFieldAddVideo;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextFieldAddVideo;
@property (weak, nonatomic) IBOutlet UITextField *latitudeLabel;
@property (weak, nonatomic) IBOutlet UITextField *longitudeLabel;

- (IBAction)getLocationDataButtonAddVideoTapped:(UIButton *)sender;
- (IBAction)useCameraForVideoButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)saveVideoButtonTapped:(UIBarButtonItem *)sender;

@end
