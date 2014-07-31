//
//  ACEMediaDetailTableViewController.m
//  arc
//
//  Created by Shree Raj Shrestha on 7/30/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEMediaDetailTableViewController.h"

@interface ACEMediaDetailTableViewController () {
    MPMoviePlayerController *videoPlayer;
    AVAudioPlayer *audioPlayer;
    NSURL *mediaFileURL;
}

@end

@implementation ACEMediaDetailTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Setting the file url
    [self setFileURL];
    
    // Enable tap recognizer if the media type is audio
    if (_mediaType == 3) {
        _tapRecognizer.enabled = YES;
        _initplayer = YES;
    }
    
    // Setting up the audio session to use speakers
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [audioSession setActive:YES error:nil];
    
    
    // Setting the preview item
    switch (_mediaType) {
            
        case 1: {
            
            // Setting the preview image
            _imagePreview.image = [UIImage imageWithContentsOfFile:[mediaFileURL path]];
            break;
        }
            
        case 2: {
            
            // Loading video on preview panel
            videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:mediaFileURL];
            videoPlayer.controlStyle = MPMovieControlStyleDefault;
            videoPlayer.scalingMode = MPMovieScalingModeAspectFit;
            videoPlayer.shouldAutoplay = NO;
            [videoPlayer.view setFrame:_preview.bounds];
            [_preview addSubview:videoPlayer.view];
            [videoPlayer play];
            [videoPlayer pause];
            break;
        }
            
        case 3: {
            
            [self generateWaveform];
            break;
        }
            
        default:
            break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    // Setting details for the detail view pane
    NSString *name = [_mediaDetail valueForKey:@"name"];
    NSString *tags = [_mediaDetail valueForKey:@"tags"];
    _nameLabel.text = name;
    _dateLabel.text = [_mediaDetail valueForKey:@"date"];
    _tagsTextView.text = tags;
    _descriptionTextView.text = [_mediaDetail valueForKey:@"descriptor"];
    
    // Getting center coordinates and region for mapview
    float latitude = [[_mediaDetail valueForKey:@"latitude"] floatValue];
    float longitude = [[_mediaDetail valueForKey:@"longitude"] floatValue];
    CLLocation *mediaLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    MKCoordinateSpan span = {.latitudeDelta =  1, .longitudeDelta =  1};
    MKCoordinateRegion region = {mediaLocation.coordinate, span};
    
    // Initializing a pin for the map
    MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
    [pin setCoordinate:mediaLocation.coordinate];
    [pin setTitle:name];
    [pin setSubtitle:tags];
    
    // Updating mapview
    _mapView.centerCoordinate = mediaLocation.coordinate;
    [_mapView setRegion:region];
    [_mapView addAnnotation:pin];
    
    // Minor hack for text view
    self.tagsTextView.selectable = NO;
    self.descriptionTextView.selectable = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFileURL
{
    NSString *fileDirectory = [[NSString alloc] init];
    
    switch (_mediaType) {
            
        case 1:
            fileDirectory = @"MyImages";
            break;
            
        case 2:
            fileDirectory = @"MyVideos";
            break;
            
        case 3:
            fileDirectory = @"MyAudios";
            break;
            
        default:
            fileDirectory = @"";
            break;
    }
    
    if (![fileDirectory  isEqual: @""]) {
        
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *pathComponent = [NSString stringWithFormat:@"/%@/%@", fileDirectory, [_mediaDetail valueForKey:@"fileName"]];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:pathComponent];
        mediaFileURL = [NSURL fileURLWithPath:filePath];
        
    } else {
        
        mediaFileURL = nil;
    }
}

-(void)generateWaveform
{
    // Generate Waveform
    NSURL *url = mediaFileURL;
    self.preview.delegate = self;
    self.preview.alpha = 0.0f;
    self.preview.audioURL = url;
    self.preview.progressSamples = 0.0f;
    self.preview.doesAllowScrubbing = NO;
    self.preview.doesAllowStretchAndScroll = NO;
}

- (void)updateWaveform
{
    // Animating the waveform
    [UIView animateWithDuration:0.01f animations:^{
        float currentPlayTime = audioPlayer.currentTime;
        float progressSample = (currentPlayTime + 0.065f) * 44100.00f;
        self.preview.progressSamples = progressSample;
    }];
}

- (IBAction)previewTouched:(UITapGestureRecognizer *)sender
{
    
    if (_initplayer) {
        
        // Setting the audioPlayer
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:mediaFileURL error:nil];
        [audioPlayer setDelegate:self];
        
        // Setting the timer to update waveform
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(updateWaveform) userInfo:nil repeats:YES];
        _initplayer = NO;
    }
    
    if (!audioPlayer.isPlaying) {
        [audioPlayer play];
    } else if (audioPlayer.isPlaying) {
        [audioPlayer pause];
    }
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender
{
    // Stop the audio player if audio is playing
    if (audioPlayer.playing) {
        [audioPlayer stop];
    }
    
    // Stop the video player if audio is playing
    if (videoPlayer.playbackState==MPMoviePlaybackStatePlaying) {
        [videoPlayer stop];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editButtonTapped:(UIBarButtonItem *)sender
{
}

- (IBAction)uploadButtonTapped:(UIBarButtonItem *)sender
{
}


#pragma mark - Table view data source

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 0;
}
 */

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [_timer invalidate];
    self.preview.progressSamples = 0.0f;
    _initplayer = YES;
}

#pragma mark - FDWaveformViewDelegate

- (void)waveformViewWillRender:(FDWaveformView *)waveformView
{
}

- (void)waveformViewDidRender:(FDWaveformView *)waveformView
{
    [UIView animateWithDuration:0.01f animations:^{
        waveformView.alpha = 1.0f;
    }];
}

@end
