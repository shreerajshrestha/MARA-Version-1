//
//  ACEVideoRecorderWindowViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 6/26/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ACEVideoRecorderWindowViewController : UIViewController

@property (strong,nonatomic) NSURL *videoURL;
@property (strong,nonatomic) MPMoviePlayerController *videoController;
@property (strong, nonatomic) IBOutlet UIImageView *thumbImage;

- (IBAction)captureButton:(UIButton *)sender;

@end
