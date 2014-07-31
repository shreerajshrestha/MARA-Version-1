//
//  ACEVideoRecorderWindowViewController.m
//  arc
//
//  Created by Shree Raj Shrestha on 6/26/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEVideoRecorderWindowViewController.h"

@interface ACEVideoRecorderWindowViewController () {
    MPMoviePlayerController *videoPlayer;
}

@property CGPoint originalCenter;

@end

@implementation ACEVideoRecorderWindowViewController {
    CLLocationManager *locationManager;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat heightOffset = keyboardSize.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - heightOffset);
    
    [UIView commitAnimations];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y);
    
    [UIView commitAnimations];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Creating the temp audio file url
    NSArray *tempFilePathComponents = [NSArray arrayWithObjects:
                                       NSTemporaryDirectory(),
                                       @"tempVideo.MOV",
                                       nil];
    _tempURL = [NSURL fileURLWithPathComponents:tempFilePathComponents];
    
    //Initializing the location manager
    locationManager = [[CLLocationManager alloc] init];
    _gotLocation = NO;
    
    self.saveAsTextField.delegate = self;
    self.tagsTextField.delegate = self;
    self.descriptionTextField.delegate = self;
    
    // Setting the default view center
    self.originalCenter = self.view.center;
    
    // Setting up the audio session to use speakers
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useCameraButtonTapped:(UIBarButtonItem *)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
        videoPicker.delegate = self;
        videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        videoPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        videoPicker.showsCameraControls = YES;
        videoPicker.allowsEditing = YES;
        
        [self presentViewController:videoPicker animated:YES completion:nil];
    }
    
    [self.saveAsTextField resignFirstResponder];
    [self.tagsTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
}

- (IBAction)getLocationDataButtonTapped:(UIButton *)sender
{
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

- (IBAction)saveVideoButtonTapped:(UIButton *)sender
{
    // Stop the video player if audio is playing
    if (videoPlayer.playbackState==MPMoviePlaybackStatePlaying) {
        [videoPlayer stop];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([_saveAsTextField.text  isEqual: @""] || _gotLocation == NO ) {
        
        UIAlertView *alertMessage = [[UIAlertView alloc]
                                     initWithTitle:@"Nothing Saved!"
                                     message:@"Please add media, enter the required fields and update location."
                                     delegate:nil
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil, nil];
        
        [alertMessage show];
        
    } else {
        
        // Start spinner animation
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]
                                            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner setCenter:CGPointMake(160,520)];
        [self.view addSubview:spinner];
        [spinner startAnimating];
        
        // Copying file from temp to documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/MyVideos"];
        
        if (![fileManager fileExistsAtPath:dataPath])
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        BOOL fileExists = NO;
        NSString *fileName = @"";
        NSURL *saveURL = [[NSURL alloc] init];
        
        do {
            int randomID = arc4random() % 9999999;
            fileName = [NSString stringWithFormat:@"%@%d.MOV",
                        [_saveAsTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""],
                        randomID];
            NSArray *saveFilePathComponents = [NSArray arrayWithObjects:
                                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                               @"/MyVideos/",
                                               fileName, nil];
            
            saveURL = [NSURL fileURLWithPathComponents:saveFilePathComponents];
            fileExists = [fileManager fileExistsAtPath:[saveURL path]];
        } while (fileExists == YES);
        
        [fileManager copyItemAtURL:_tempURL toURL:saveURL error:nil];
        
        // Generating and saving thumbnail to cache
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_tempURL options:nil];
        AVAssetImageGenerator *thumbGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        thumbGenerator.appliesPreferredTrackTransform = YES;
        int totalSeconds = CMTimeGetSeconds([asset duration]);
        CMTime time = CMTimeMake(totalSeconds, 10);
        CGImageRef referenceImage = [thumbGenerator copyCGImageAtTime:time actualTime:NULL error:nil];
        UIImage *snapshotImage = [[UIImage alloc] initWithCGImage:referenceImage];
        
        CGSize thumbnailSize = CGSizeMake(256,256);
        UIGraphicsBeginImageContext(thumbnailSize);
        CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
        thumbnailRect.origin = CGPointMake(0.0,0.0);
        thumbnailRect.size.width  = thumbnailSize.width;
        thumbnailRect.size.height = thumbnailSize.height;
        [snapshotImage drawInRect:thumbnailRect];
        UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *thumbCacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"/Caches/ThumbnailCache"];
        if (![fileManager fileExistsAtPath:thumbCacheDirectory])
            [fileManager createDirectoryAtPath:thumbCacheDirectory withIntermediateDirectories:NO attributes:nil error:nil];
        NSString *thumbPathComponent = [NSString stringWithFormat:@"/%@thumb.jpg",fileName];
        NSString *cachePath = [thumbCacheDirectory stringByAppendingPathComponent:thumbPathComponent];
        
        [UIImageJPEGRepresentation(thumbnailImage, 1.0) writeToFile:cachePath atomically:YES];
        
        // Formatting date
        NSDate *now = [[NSDate alloc] init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
        NSString *date = [formatter stringFromDate:now];
        
        // Saving the details to core data
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSManagedObject *newTagObject;
        newTagObject = [NSEntityDescription
                        insertNewObjectForEntityForName:@"VideoDB"
                        inManagedObjectContext:context];
        
        [newTagObject setValue: _saveAsTextField.text forKey:@"name"];
        [newTagObject setValue: _tagsTextField.text forKey:@"tags"];
        [newTagObject setValue: _descriptionTextField.text forKey:@"descriptor"];
        [newTagObject setValue:[NSNumber numberWithFloat:_latitude] forKey:@"latitude"];
        [newTagObject setValue:[NSNumber numberWithFloat:_longitude] forKey:@"longitude"];
        [newTagObject setValue: date forKey:@"date"];
        [newTagObject setValue: fileName forKey:@"fileName"];
        
        // Save the new TagObject to persistent store
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Save failed with error: %@ %@", error, [error localizedDescription]);
        } else {
            UIAlertView *savedMessage = [[UIAlertView alloc]
                                         initWithTitle:@""
                                         message:@"Successfully saved!"
                                         delegate:nil
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
            
            [savedMessage show];
        }
        
        // Deleting the temp file if it exists
        if ([fileManager fileExistsAtPath:[_tempURL path]]) {
            [fileManager removeItemAtPath:[_tempURL path] error:nil];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender
{
    // Stop the video player if audio is playing
    if (videoPlayer.playbackState==MPMoviePlaybackStatePlaying) {
        [videoPlayer stop];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Deleting the temp file
    if ([fileManager fileExistsAtPath:[_tempURL path]]) {
        [fileManager removeItemAtPath:[_tempURL path] error:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    // Enable tags and description fields
    if (textField == _saveAsTextField) {
        _tagsTextField.enabled = YES;
        _descriptionTextField.enabled = YES;
        _getLocationDataButton.enabled = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _saveAsTextField || textField == _tagsTextField || textField == _descriptionTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)videoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Saving the captured video to temp directory and loading preview
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        
        NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:[_tempURL path] error:nil];
        [manager copyItemAtURL:mediaURL toURL:_tempURL error:nil];
        
        // Setting up the audio session to use speakers
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        [audioSession setActive:YES error:nil];
        
        // Loading video on preview pane
        videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:_tempURL];
        videoPlayer.controlStyle = MPMovieControlStyleDefault;
        videoPlayer.scalingMode = MPMovieScalingModeAspectFit;
        videoPlayer.shouldAutoplay = NO;
        [videoPlayer.view setFrame:_preview.bounds];
        [_preview addSubview:videoPlayer.view];
        [videoPlayer play];
        [videoPlayer pause];
    }
    
    _saveAsTextField.enabled = YES;
    
    [videoPicker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)videoPicker
{
    [videoPicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *errorAlert= [[UIAlertView alloc]
                              initWithTitle:@"Error!"
                              message:@"Failed to get your location!"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
    
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    
    if (currentLocation != nil) {
        // Updating local latitude and longtitude
        _latitude = currentLocation.coordinate.latitude;
        _longitude = currentLocation.coordinate.longitude;
        
        // Updating latitude and longitude text fields
        _latitudeLabel.text = [NSString stringWithFormat:@"%.8f", _latitude];
        _longitudeLabel.text = [NSString stringWithFormat:@"%.8f", _longitude];
        
        _gotLocation = YES;
    }
    
    [locationManager stopUpdatingLocation];
}

@end
