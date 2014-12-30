//
//  ACEMediaDetailTableViewController.m
//  arc
//
//  Created by Shree Raj Shrestha on 7/30/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEMediaDetailTableViewController.h"
#import "ACEWebViewController.h"
#import "Reachability.h"
#include <CFNetwork/CFNetwork.h>

enum {
    kSendBufferSize = 32768
};

@interface ACEMediaDetailTableViewController () <NSStreamDelegate, NSURLConnectionDataDelegate> {
    MPMoviePlayerController *videoPlayer;
    AVAudioPlayer *audioPlayer;
    NSURL *mediaFileURL;
    NSString *webURL;
    NSString *event;
}

@property (nonatomic, strong) NSOutputStream *networkStream;
@property (nonatomic, strong) NSInputStream *fileStream;
@property (nonatomic, assign, readonly ) uint8_t *buffer;
@property (nonatomic, assign, readwrite) size_t bufferOffset;
@property (nonatomic, assign, readwrite) size_t bufferLimit;

@end

@implementation ACEMediaDetailTableViewController
{
    uint8_t _buffer[kSendBufferSize];
}

- (uint8_t *)buffer
{
    return self->_buffer;
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && ([trimmedStr length] != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"ftp"  options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}

- (void)updateStatus:(NSString *)statusString withTitle:(NSString *)statusTitle
{
    assert(statusString != nil);
    UIAlertView *alertMessage = [[UIAlertView alloc]
                                 initWithTitle:statusTitle
                                 message:statusString
                                 delegate:nil
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil, nil];
    [alertMessage show];
}

- (void)stopUploadWithStatus:(NSString *)statusString withTitle:(NSString *)statusTitle
{
    // Close network stream
    [_networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _networkStream.delegate = nil;
    [_networkStream close];
    _networkStream = nil;
    
    // Close file stream
    [_fileStream close];
    _fileStream = nil;
    
    // Update UI
    if (_uploadSuccess) {
        _uploadButton.enabled = NO;
        _publishButton.enabled = YES;
        _uploadButton.title = @"Online";
    } else {
        _uploadButton.enabled = YES;
        _uploadButton.title = @"Upload";
    }
    _backButton.enabled = YES;
    
    [self updateStatus:statusString withTitle:statusTitle];
}

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
}

-(void)viewDidAppear:(BOOL)animated
{
    
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
            videoPlayer.controlStyle = MPMovieControlStyleEmbedded;
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
    MKCoordinateSpan span = {.latitudeDelta =  0.25, .longitudeDelta =  0.25};
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
    
    // Default UI
    _uploadButton.enabled = YES;
    _uploadButton.title = @"Upload";
    _publishButton.enabled = NO;
    
    // Check for internet connection
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if (internetStatus != NotReachable) {
        
        // Check if file exists at webURL
        NSURL *url = [NSURL URLWithString:[_mediaDetail valueForKey:@"webURL"]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
        
        if(urlConnection != nil)
            urlConnection = nil;
        
    } else {
        _uploadButton.enabled = NO;
        _publishButton.enabled = NO;
        _uploadButton.title = @"";
        _publishButton.title = @"";
    }
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
    if ([_editButton.title  isEqual: @"Done"]) {
        
        [_mediaDetail setValue: _tagsTextView.text forKey:@"tags"];
        [_mediaDetail setValue: _descriptionTextView.text forKey:@"descriptor"];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        [context save:nil];
        
        _editButton.title = @"Edit";
        _tagsTextView.editable = NO;
        _descriptionTextView.editable = NO;
        _backButton.enabled = YES;
        _backButton.title = @"Back";
        _publishButton.enabled = YES;
        _uploadButton.enabled = YES;
        
    } else {
        
        _editButton.title = @"Done";
        _tagsTextView.editable = YES;
        _descriptionTextView.editable = YES;
        _backButton.enabled = NO;
        _backButton.title = @"PRESS DONE TO END EDITING";
        _publishButton.enabled = NO;
        _uploadButton.enabled = NO;
        [_descriptionTextView becomeFirstResponder];
        [_tagsTextView becomeFirstResponder];
        
    }
    
    
}

- (IBAction)uploadButtonTapped:(UIBarButtonItem *)sender
{
    _uploadSuccess = NO;
    _uploadButton.enabled = NO;
    _backButton.enabled = NO;
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *ftpHost = [settings stringForKey:@"SettingsFTPHost"];
    NSString *ftpDir = [settings stringForKey:@"SettingsFTPDirectory"];
    NSString *ftpDirMask = [settings stringForKey:@"SettingsFTPDirectoryMask"];
    NSString *ftpURLString = [NSString stringWithFormat:@"%@%@",ftpHost,ftpDir];
    NSString *username = [settings stringForKey:@"SettingsFTPUsername"];
    NSString *password = [settings stringForKey:@"SettingsFTPPassword"];
    NSString *filePath = [mediaFileURL path];
    BOOL success;
    
    assert(self.networkStream == nil);
    assert(self.fileStream == nil);
    
    _fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    [_fileStream open];
    
    // Modify url is filetype is video, hack to get around converting .mov to .mp4
    if (_mediaType == 2 ) {
        filePath = [filePath stringByReplacingOccurrencesOfString:@".MOV" withString:@".mp4"];
    }
    
    NSURL *ftpURL = [self smartURLForString:ftpURLString];
    ftpURL = CFBridgingRelease(
                               CFURLCreateCopyAppendingPathComponent(NULL, (__bridge CFURLRef) ftpURL, (__bridge CFStringRef) [filePath lastPathComponent], false)
                               );
    _networkStream = CFBridgingRelease(
                                       CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) ftpURL)
                                       );
    success = [_networkStream setProperty:username forKey:(id)kCFStreamPropertyFTPUserName];
    assert(success);
    success = [_networkStream setProperty:password forKey:(id)kCFStreamPropertyFTPPassword];
    assert(success);
    
    if ([ftpDirMask length]==0) {
        webURL = [[ftpURL absoluteString] stringByReplacingOccurrencesOfString:@"ftp://" withString:@"http://"];
    } else {
        webURL = [NSString stringWithFormat:@"http://%@%@%@",ftpHost,ftpDirMask,[filePath lastPathComponent]];
    }
    
    NSLog(@"%@",webURL);
    
    _networkStream.delegate = self;
    [_networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_networkStream open];
}

- (IBAction)publishButtonTapped:(UIBarButtonItem *)sender {
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    // Checking if the segue is the one to detail view
    if ([segue.identifier isEqualToString:@"showWebView"]) {
        
        ACEWebViewController *destViewController = (ACEWebViewController *)[[segue destinationViewController] topViewController];
        destViewController.mediaDetail = _mediaDetail;
        destViewController.mediaType = _mediaType;
    }
    
}



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

#pragma mark - NSURLConnectionDelegate

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = (int)[httpResponse statusCode];
    
    // If file exists, update UI accordingly
    if (code == 200) {
        _uploadButton.enabled = NO;
        _uploadButton.title = @"Online";
        _publishButton.enabled = YES;
    }
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
#pragma unused(aStream)
    assert(aStream == _networkStream);
    
    switch (eventCode) {
            
        case NSStreamEventOpenCompleted: {
            _uploadButton.title = @"Uploading";
        } break;
            
        case NSStreamEventHasBytesAvailable: {
            assert(NO);
        } break;
            
        case NSStreamEventHasSpaceAvailable: {
            
            // If we don't have any data buffered, go read the next chunk of data.
            
            if (_bufferOffset == _bufferLimit) {
                NSInteger   bytesRead;
                
                bytesRead = [_fileStream read:_buffer maxLength:kSendBufferSize];
                
                if (bytesRead == -1) {
                    [self stopUploadWithStatus:@"There was a problem reading the local file."
                                     withTitle:@"File Read Error!"];
                } else if (bytesRead == 0) {
                    
                    _uploadSuccess = YES;
                    [self stopUploadWithStatus:@"You may now proceed to publish the media."
                                     withTitle:@"Successfully Uploaded!"];
                    
                    [_mediaDetail setValue:webURL forKey:@"webURL"];
                    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                    NSManagedObjectContext *context = [appDelegate managedObjectContext];
                    [context save:nil];
                    
                } else {
                    _bufferOffset = 0;
                    _bufferLimit  = bytesRead;
                }
            }
            
            // If we're not out of data completely, send the next chunk.
            
            if (_bufferOffset != _bufferLimit) {
                NSInteger   bytesWritten;
                bytesWritten = [_networkStream write:&_buffer[_bufferOffset] maxLength:_bufferLimit - _bufferOffset];
                assert(bytesWritten != 0);
                if (bytesWritten == -1) {
                    [self stopUploadWithStatus:@"There was a problem writing to the network."
                                     withTitle:@"Network Write Error!"];
                } else {
                    _bufferOffset += bytesWritten;
                }
            }
        } break;
            
        case NSStreamEventErrorOccurred: {
            [self stopUploadWithStatus:@"Please make sure there is a working internet connection and the FTP details are entered correctly."
                             withTitle:@"Stream Open Error!"];
        } break;
            
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
            
        default: {
            assert(NO);
        } break;
            
    }
}

@end
