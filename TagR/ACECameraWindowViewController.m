//
//  ACECameraWindowViewController.m
//  TagR
//
//  Created by Shree Raj Shrestha on 6/21/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACECameraWindowViewController.h"

@interface ACECameraWindowViewController () {
    float latitude;
    float longitude;
}

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
    
    _saveAsTextField.enabled = YES; //FOR NOW
    
    //Initializing the location manager
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
        imagePicker.allowsEditing = YES;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        //        _newMedia = YES;
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
    // Validation routine to allow saving
    // ****** Update this to check file URL and location is there
    // deciding whether to put cancel button or not
    if ([_saveAsTextField.text  isEqual: @""] || _gotLocation == NO ) {

        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        // Creating a new TagObject entity
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        NSManagedObject *newTagObject;
        newTagObject = [NSEntityDescription
                        insertNewObjectForEntityForName:@"ImageDB"
                        inManagedObjectContext:context];
        
        [newTagObject setValue: _saveAsTextField.text forKey:@"name"];
        [newTagObject setValue: _tagsTextField.text forKey:@"tags"];
        [newTagObject setValue: _descriptionTextField.text forKey:@"descriptor"];
        [newTagObject setValue:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
        [newTagObject setValue:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
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

-(void)imagePickerController:(UIImagePickerController *)imagePicker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //UIImage *image = info[UIImagePickerControllerOriginalImage];
        
       //decided to take image view out, assign image url to this image here
        //_imageView.image = image;
        
        //some code to get the TEMP file URL here
    }
    _imageURL = info[UIImagePickerControllerMediaURL];
    _saveAsTextField.enabled = YES;
    
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

//-(void)image:(UIImage *)image
//finishedSavingWithError:(NSError *)error
// contextInfo:(void *)contextInfo
//{
//    if (error) {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle: @"Error!"
//                              message: @"Failed to save image!"
//                              delegate: nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//        [alert show];
//    }
//}

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
        latitude = currentLocation.coordinate.latitude;
        longitude = currentLocation.coordinate.longitude;
        
        // Updating latitude and longitude text fields
        _latitudeLabel.text = [NSString stringWithFormat:@"%.8f", latitude];
        _longitudeLabel.text = [NSString stringWithFormat:@"%.8f", longitude];
        
        _gotLocation = YES;
    }
    
    [locationManager stopUpdatingLocation];
}

@end
