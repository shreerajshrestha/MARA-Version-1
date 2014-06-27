//
//  ACERecorderViewController.m
//  TagR
//
//  Created by Shree Raj Shrestha on 6/27/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACERecorderViewController.h"

@interface ACERecorderViewController () {
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
    
    //*******                               ********//
    //******* Add Error Handling code here  ********//
    //*******                               ********//
    
    // Disable Stop/Play button when application launches
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:NO];
    
    // Seting up the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    //Setting up the audio session
    AVAudioSession *recorderSession = [AVAudioSession sharedInstance];
    [recorderSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //Defining the audio recorder settings
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    //Initiating and preparing the audio recorder
    audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    audioRecorder.delegate = self;
    audioRecorder.meteringEnabled = YES;
    [audioRecorder prepareToRecord];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)recordPauseButtonTapped:(UIButton *)sender {
    
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

- (IBAction)playButtonTapped:(UIButton *)sender {
    
    if (!audioRecorder.recording) {
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioRecorder.url error:nil];
        [audioPlayer setDelegate:self];
        [audioPlayer play];
    }
    
}

- (IBAction)stopButtonTapped:(UIButton *)sender {
    
    [audioRecorder stop];
    
    AVAudioSession *recorderAudioSession = [AVAudioSession sharedInstance];
    [recorderAudioSession setActive:NO error:nil];
    
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
    [_recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [_stopButton setEnabled:NO];
    [_playButton setEnabled:YES];
}

@end
