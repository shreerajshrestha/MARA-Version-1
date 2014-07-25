//
//  ACERecorderViewController.m
//  arc
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
    
    // Deleting the temp file if it exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_tempFileURL path]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[_tempFileURL path] error:nil];
    }
    
    // Setting up the audio session
    AVAudioSession *recorderSession = [AVAudioSession sharedInstance];
    [recorderSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Defining the audio recorder settings
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiating and preparing the audio recorder
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:_tempFileURL settings:recordSetting error:NULL];
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    [audioRecorder prepareToRecord];
    
    // Setting graphical properties for waveform view
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
    // Stopping the audio player before recording
    if (audioPlayer.playing) {
        [audioPlayer stop];
        self.waveform.progressSamples = 0;
    }
    
    if (!audioRecorder.recording) {
        
        AVAudioSession *recorderSession = [AVAudioSession sharedInstance];
        [recorderSession setActive:YES error:nil];
        
        // Start recording
        [audioRecorder record];
        [_recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
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
    
    [self reset];
    [self generateWaveform];
}

- (IBAction)playButtonTapped:(UIButton *)sender
{
    if (!audioRecorder.recording) {
        
        if (_initplayer) {
            
            // Setting the audioPlayer
            audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_tempFileURL error:nil];
            [audioPlayer setDelegate:self];
            
            // Setting the timer to update waveform
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateWaveform) userInfo:nil repeats:YES];
            _initplayer = NO;
        }
        
        
        if (!audioPlayer.isPlaying) {
            [audioPlayer play];
            [_playButton setTitle:@"Pause" forState:UIControlStateNormal];
        } else if (audioPlayer.isPlaying) {
            [audioPlayer pause];
            [_playButton setTitle:@"Play" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)doneButtonForRecordingTapped:(UIButton *)sender
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_tempFileURL path]]) {
        [_delegate isFileSaved:YES];
    } else {
        [_delegate isFileSaved:NO];
    }
    
    [audioPlayer stop];
    [self reset];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) generateWaveform
{
    // Generate Waveform
    NSURL *url = _tempFileURL;
    self.waveform.delegate = self;
    self.waveform.alpha = 0.0f;
    self.waveform.audioURL = url;
    self.waveform.progressSamples = 0;
    self.waveform.doesAllowScrubbing = NO;
    self.waveform.doesAllowStretchAndScroll = NO;
}

- (void)updateWaveform
{
    // Animating the waveform
    [UIView animateWithDuration:0.01 animations:^{
        float currentPlayTime = audioPlayer.currentTime;
        float progressSample = ( currentPlayTime + 0.10 ) * 44100.00;
        self.waveform.progressSamples = progressSample;
    }];
}

- (void)reset
{
    [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    [_timer invalidate];
    self.waveform.progressSamples = 0;
    _initplayer = YES;
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

#pragma mark - AVAudioRecorderDelegate
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:YES];
    [_doneButton setEnabled:YES];
    [self reset];
}


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self reset];
}

#pragma mark - FDWaveformViewDelegate

- (void)waveformViewWillRender:(FDWaveformView *)waveformView
{
    
}

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    [UIView animateWithDuration:0.25f animations:^{
        waveformView.alpha = 1.0f;
    }];
}

@end
