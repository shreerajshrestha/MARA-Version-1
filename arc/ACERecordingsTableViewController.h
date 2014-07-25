//
//  ACERecordingsTableViewController.h
//  TagR
//
//  Created by Shree Raj Shrestha on 6/20/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ACERecordingsTableViewController : UITableViewController
<AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@end
