//
//  ACEImageTableViewCell.h
//  TagR
//
//  Created by Shree Raj Shrestha on 7/14/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACEImageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *tags;

@end
