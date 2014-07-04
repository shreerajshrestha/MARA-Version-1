//
//  ACEVideoRecorderWindowViewController.m
//  TagR
//
//  Created by Shree Raj Shrestha on 6/26/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEVideoRecorderWindowViewController.h"
//#import <AVFoundation/AVFoundation.h>

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
    
    _saveAsTextField.enabled = YES; //FOR NOW
    
    //Initializing the location manager
    locationManager = [[CLLocationManager alloc] init];
    
    self.saveAsTextField.delegate = self;
    self.tagsTextField.delegate = self;
    self.descriptionTextField.delegate = self;
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
        videoPicker.allowsEditing = YES;
        
        [self presentViewController:videoPicker animated:YES completion:nil];
    }
}

- (IBAction)getLocationDataButtonTapped:(UIButton *)sender
{
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

- (IBAction)saveVideoButtonTapped:(UIBarButtonItem *)sender
{
    if ([_saveAsTextField.text  isEqual: @""] || _gotLocation == NO ) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        // Creating a new TagObject entity
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
        [newTagObject setValue: _datePicker.date forKey:@"date"];
        
        //***** code to set file URL and webURL still needed
        //    [newTagObject setValue: [THE FILE URL] forKey:@"fileURL"];
        //    [newTagObject setValue: [THE WEB URL] forKey:@"webURL"]; //May be in uploader
        
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
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    // Enable tags and description fields if Save As field is not empty
    if (textField == _saveAsTextField) {
        if ( [textField.text length] == 0 ) {
            _tagsTextField.enabled = NO;
            _descriptionTextField.enabled = NO;
            _getLocationDataButton.enabled = NO;
        } else {
            _tagsTextField.enabled = YES;
            _descriptionTextField.enabled = YES;
            _getLocationDataButton.enabled = YES;
        }
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
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        //UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        //decided to take image view out, assign image url to this image here
        //_imageView.image = image;
        
        //some code to get the TEMP file URL here
    }
    _videoURL = info[UIImagePickerControllerMediaURL];
    _saveAsTextField.enabled = YES;
    
    [videoPicker dismissViewControllerAnimated:YES completion:NULL];
    
    //initializing the video controller in the header file
//    self.videoController = [[MPMoviePlayerController alloc] init];
//    
//    [self.videoController setContentURL:self.videoURL];
//    [self.videoController.view setFrame:CGRectMake(0, 50, 200, 300)];
//    [self.view addSubview:self.videoController.view]; //setting and displaying a subview
//    
//    [self.videoController play];
    
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
    [videoPicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // NSLog(@"didFailWithError: %@",error);
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
    // NSLog(@"didUpdateLocations: %@", currentLocation);
    
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
