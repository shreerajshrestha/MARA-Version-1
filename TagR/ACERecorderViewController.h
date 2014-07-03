//
//  ACERecorderViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 6/27/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FDWaveformView.h"

@interface ACERecorderViewController : UIViewController
<AVAudioPlayerDelegate, AVAudioRecorderDelegate, FDWaveformViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet FDWaveformView *waveform;

- (IBAction)recordPauseButtonTapped:(UIButton *)sender;
- (IBAction)playButtonTapped:(UIButton *)sender;
- (IBAction)stopButtonTapped:(UIButton *)sender;
- (IBAction)doneButtonForRecordingTapped:(UIBarButtonItem *)sender;


- (void)updateWaveform;

@end
