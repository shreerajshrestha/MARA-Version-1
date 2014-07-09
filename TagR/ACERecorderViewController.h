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

@protocol RecordingStateDelegate <NSObject>
- (void)isFileSaved:(BOOL) saved;
@end

@interface ACERecorderViewController : UIViewController
<AVAudioPlayerDelegate, AVAudioRecorderDelegate, FDWaveformViewDelegate>

//Protocol properties for delegate
@property (weak, nonatomic) id <RecordingStateDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet FDWaveformView *waveform;
@property (strong, nonatomic) NSURL *tempFileURL;
@property (strong, nonatomic) NSTimer *timer;

- (IBAction)recordPauseButtonTapped:(UIButton *)sender;
- (IBAction)playButtonTapped:(UIButton *)sender;
- (IBAction)stopButtonTapped:(UIButton *)sender;
- (IBAction)doneButtonForRecordingTapped:(UIButton *)sender;

- (void)updateWaveform;

@end
