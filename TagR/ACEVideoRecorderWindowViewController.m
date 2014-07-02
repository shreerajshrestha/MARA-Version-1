//
//  ACEVideoRecorderWindowViewController.m
//  TagR
//
//  Created by Shree Raj Shrestha on 6/26/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEVideoRecorderWindowViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ACEVideoRecorderWindowViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    locationManager = [[CLLocationManager alloc] init];
    
    self.saveAsTextFieldAddVideo.delegate = self;
    self.tagsTextFieldAddVideo.delegate = self;
    self.descriptionTextFieldAddVideo.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)useCameraForVideoButtonTapped:(UIBarButtonItem *)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
        videoPicker.delegate = self;
        videoPicker.allowsEditing = YES;
        videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoPicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        [self presentViewController:videoPicker animated:YES completion:NULL];
    }
}

- (IBAction)saveVideoButtonTapped:(UIBarButtonItem *)sender
{
    //*************
    //Code to save the video here
    //**************
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getLocationDataButtonAddVideoTapped:(UIButton *)sender
{
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.saveAsTextFieldAddVideo || textField == self.tagsTextFieldAddVideo || textField == self.descriptionTextFieldAddVideo) {
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
    self.videoURL = info[UIImagePickerControllerMediaURL];
    [videoPicker dismissViewControllerAnimated:YES completion:NULL];
    
    //initializing the video controller in the header file
    self.videoController = [[MPMoviePlayerController alloc] init];
    
    [self.videoController setContentURL:self.videoURL];
    [self.videoController.view setFrame:CGRectMake(0, 50, 200, 300)];
    [self.view addSubview:self.videoController.view]; //setting and displaying a subview
    
    [self.videoController play];
    
    //MEthod to generate thumbnail, some error logging method here
    
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
//    AVAssetImageGenerator *thumbGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    NSError *error = NULL;
//    CMTime time = CMTimeMake(1, 65);
//    CGImageRef thumbRef = [thumbGen copyCGImageAtTime:time actualTime:NULL error:&error];
//    NSLog(@"error==%@, Refimage==%@", error, thumbRef);
//    UIImage *thumbImg= [[UIImage alloc] initWithCGImage:thumbRef];
//    
//    self.thumbImage.image = thumbImg;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)videoPicker
{
    [videoPicker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@",error);
    UIAlertView *errorAlert= [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to get your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    NSLog(@"didUpdateLocations: %@", currentLocation);
    
    if (currentLocation != nil) {
        _latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        _longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    }
    
    [locationManager stopUpdatingLocation];
}

@end
