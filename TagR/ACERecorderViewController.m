//
//  ACERecorderViewController.m
//  TagR
//
//  Created by Shree Raj Shrestha on 6/27/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACERecorderViewController.h"

@interface ACERecorderViewController ()
{
    AVAudioRecorder *audioRecorder;
    AVAudioPlayer *audioPlayer;
}

@end

@implementation ACERecorderViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Disable Stop/Play button when application launches
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:NO];
    [_doneButton setEnabled:NO];
    
    // Seting up the temp file url
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               NSTemporaryDirectory(),
                               @"tempAudio.m4a",
                               nil];
    _tempFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    //Deleting the temp file if it exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_tempFileURL path]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[_tempFileURL path] error:nil];
    }
    
    //Setting up the audio session
    AVAudioSession *recorderSession = [AVAudioSession sharedInstance];
    [recorderSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //Defining the audio recorder settings
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    //Initiating and preparing the audio recorder
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:_tempFileURL settings:recordSetting error:NULL];
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    [audioRecorder prepareToRecord];
    
    //Setting graphical properties for waveform view
    self.waveform.backgroundColor = [UIColor lightGrayColor];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)recordPauseButtonTapped:(UIButton *)sender
{
    //Stopping the audio player before recording
    if (audioPlayer.playing) {
        [audioPlayer stop];
    }
    
    if (!audioRecorder.recording) {
        
        AVAudioSession *recorderSession = [AVAudioSession sharedInstance];
        [recorderSession setActive:YES error:nil];
        
        //Start recording
        [audioRecorder record];
        [_recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        //Pause recording
        [audioRecorder pause];
        [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
        
    }
    
    [_stopButton setEnabled: YES];
    [_playButton setEnabled: NO];
}

- (IBAction)stopButtonTapped:(UIButton *)sender
{
    [audioRecorder stop];
    
    AVAudioSession *recorderAudioSession = [AVAudioSession sharedInstance];
    [recorderAudioSession setActive:NO error:nil];
    
    //code to generate the FDWaveform
    NSURL *url = _tempFileURL;
    self.waveform.delegate = self;
    self.waveform.alpha = 0.0f;
    self.waveform.audioURL = url;
    self.waveform.progressSamples = 0;
    self.waveform.doesAllowScrubbing = NO;
    self.waveform.doesAllowStretchAndScroll = NO;
}

- (IBAction)playButtonTapped:(UIButton *)sender
{
    if (!audioRecorder.recording) {
        
        //Setting the audioPlayer
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:nil];
        [audioPlayer setDelegate:self];
        
        //Setting the timer to update waveform
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.10 target:self selector:@selector(updateWaveform) userInfo:nil repeats:YES];
        
        //Playing the audio
        [audioPlayer play];
    }
}

- (IBAction)doneButtonForRecordingTapped:(UIButton *)sender
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_tempFileURL path]]) {
        [_delegate isFileSaved:YES];
    } else {
        [_delegate isFileSaved:NO];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateWaveform
{
    //Animating the waveform
    [UIView animateWithDuration:0.10 animations:^{
        float currentPlayTime = audioPlayer.currentTime;
        float progressSample = ( currentPlayTime + 0.15 ) * 44100.00;
        self.waveform.progressSamples = progressSample;
    }];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:YES];
    [_doneButton setEnabled:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)audioPlayer successfully:(BOOL)flag
{
    // Music completed so stop timer
    if (flag) {
        [_timer invalidate];
    }
}

#pragma mark - FDWaveformViewDelegate

- (void)waveformViewWillRender:(FDWaveformView *)waveformView
{
    //self.startRendering = [NSDate date];
}

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    //NSLog(@"FDWaveformView rendering done, took %f seconds", -[self.startRendering timeIntervalSinceNow]);
    [UIView animateWithDuration:0.25f animations:^{
        waveformView.alpha = 1.0f;
    }];
}

@end
