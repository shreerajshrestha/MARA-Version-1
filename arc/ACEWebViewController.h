//
//  ACEWebViewController.h
//  arc
//
//  Created by Shree Raj Shrestha on 8/22/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ACEWebViewController : UIViewController
<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSManagedObject *mediaDetail;
@property int mediaType;

@end
