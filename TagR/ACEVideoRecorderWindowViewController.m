//
//  ACEVideoRecorderWindowViewController.m
//  TagR
//
//  Created by Shree Raj Shrestha on 6/26/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEVideoRecorderWindowViewController.h"

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
    self.saveAsTextField.enabled = YES;
    
    //Initializing the location manager
    locationManager = [[CLLocationManager alloc] init];
    _gotLocation = NO;
    
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
    // Creating the temp audio file url
    NSArray *tempFilePathComponents = [NSArray arrayWithObjects:
                                       NSTemporaryDirectory(),
                                       @"tempVideo.MOV",
                                       nil];
    NSURL *tempURL = [NSURL fileURLWithPathComponents:tempFilePathComponents];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([_saveAsTextField.text  isEqual: @""] || _gotLocation == NO ) {
        
        // Deleting the temp file
        if ([fileManager fileExistsAtPath:[tempURL path]]) {
            [fileManager removeItemAtPath:[tempURL path] error:nil];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        // Copying file from temp to documents directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/MyVideos"];
        
        if (![fileManager fileExistsAtPath:dataPath])
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        BOOL fileExists = NO;
        NSString *saveName = @"";
        NSURL *saveURL = [[NSURL alloc] init];
        
        do {
            int randomID = arc4random() % 9999999;
            saveName = [NSString stringWithFormat:@"%@%d.MOV",
                        [_saveAsTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""],
                        randomID];
            NSArray *saveFilePathComponents = [NSArray arrayWithObjects:
                                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                               @"/MyVideos/",
                                               saveName, nil];
            
            saveURL = [NSURL fileURLWithPathComponents:saveFilePathComponents];
            fileExists = [fileManager fileExistsAtPath:[saveURL path]];
        } while (fileExists == YES);
        
        // Copying files from temp to documents directory
        [fileManager copyItemAtURL:tempURL toURL:saveURL error:nil];
        
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
        [newTagObject setValue: _datePicker.date forKey:@"date"];
        [newTagObject setValue: saveName forKey:@"fileName"];
        //    [newTagObject setValue: [THE WEB URL] forKey:@"webURL"]; //This to be added by uploader
        
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
        if ([fileManager fileExistsAtPath:[tempURL path]]) {
            [fileManager removeItemAtPath:[tempURL path] error:nil];
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
    // Seting up the temp file url
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               NSTemporaryDirectory(),
                               @"tempVideo.MOV",
                               nil];
    NSURL *tempURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Saving the captured video to temp directory
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager copyItemAtURL:mediaURL toURL:tempURL error:nil];

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
