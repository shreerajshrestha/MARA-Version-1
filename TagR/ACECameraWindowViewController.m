//
//  ACECameraWindowViewController.m
//  arc
//
//  Created by Shree Raj Shrestha on 6/21/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACECameraWindowViewController.h"

@interface ACECameraWindowViewController ()

@end

@implementation ACECameraWindowViewController {
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
    
    // Initializing the location manager
    locationManager = [[CLLocationManager alloc] init];
    _gotLocation = NO;
    
    // Delegating the text fields
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        imagePicker.showsCameraControls = YES;
        imagePicker.allowsEditing = YES;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (IBAction)getLocationDataButtonTapped:(UIButton *)sender
{
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [locationManager startUpdatingLocation];
}

- (IBAction)saveImageButtonTapped:(UIBarButtonItem *)sender
{
    // Creating the temp audio file url
    NSArray *tempFilePathComponents = [NSArray arrayWithObjects:
                                       NSTemporaryDirectory(),
                                       @"tempImage.jpg",
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
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/MyImages"];
        
        if (![fileManager fileExistsAtPath:dataPath])
            [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
        
        BOOL fileExists = NO;
        NSString *saveName = @"";
        NSURL *saveURL = [[NSURL alloc] init];
        
        do {
            int randomID = arc4random() % 9999999;
            saveName = [NSString stringWithFormat:@"%@%d.jpg",
                                  [_saveAsTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""],
                                  randomID];
            NSArray *saveFilePathComponents = [NSArray arrayWithObjects:
                                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                               @"/MyImages/",
                                               saveName, nil];
            
            saveURL = [NSURL fileURLWithPathComponents:saveFilePathComponents];
            fileExists = [fileManager fileExistsAtPath:[saveURL path]];
        } while (fileExists == YES);
        
        [fileManager copyItemAtURL:tempURL toURL:saveURL error:nil];
        
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
                        insertNewObjectForEntityForName:@"ImageDB"
                        inManagedObjectContext:context];
        
        [newTagObject setValue: _saveAsTextField.text forKey:@"name"];
        [newTagObject setValue: _tagsTextField.text forKey:@"tags"];
        [newTagObject setValue: _descriptionTextField.text forKey:@"descriptor"];
        [newTagObject setValue:[NSNumber numberWithFloat:_latitude] forKey:@"latitude"];
        [newTagObject setValue:[NSNumber numberWithFloat:_longitude] forKey:@"longitude"];
        [newTagObject setValue: date forKey:@"date"];
        [newTagObject setValue: saveName forKey:@"fileName"];
        
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

-(void)imagePickerController:(UIImagePickerController *)imagePicker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Seting up the temp file url
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               NSTemporaryDirectory(),
                               @"tempImage.jpg",
                               nil];
    NSURL *tempURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Saving the captured image to temp directory
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[tempURL path] atomically:YES];
    }
    
    _saveAsTextField.enabled = YES;
    
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
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
