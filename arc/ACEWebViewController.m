//
//  ACEWebViewController.m
//  arc
//
//  Created by Shree Raj Shrestha on 8/22/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEWebViewController.h"
#include <CFNetwork/CFNetwork.h>

@interface ACEWebViewController ()

@property (nonatomic, strong) NSString *blogURL;
@property (nonatomic, strong) NSString *login;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *postTitle;
@property (nonatomic, strong) NSString *tags;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *postFormat;
@property (nonatomic, strong) NSString *captureDate;
@property float latitude;
@property float longitude;

@end

@implementation ACEWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _blogURL = [[NSUserDefaults standardUserDefaults] stringForKey:@"SettingsBlogURL"];
    
    if ( _blogURL.length == 0 ) {
        
        UIAlertView *statusMessage = [[UIAlertView alloc]
                                      initWithTitle:@"Blog URL not set!"
                                      message:@"Please set the blog url in the settings!"
                                      delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"OK", nil];
        statusMessage.tag = 1000;
        statusMessage.delegate = self;
        [statusMessage show];
        
    } else {
        
        // Initializing webview
        NSString *postURL = [NSString stringWithFormat:@"http://%@/wp-admin/post-new.php",_blogURL];
        NSURL *url = [NSURL URLWithString:postURL];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        // Initializing login details from the plist file
        _login = [[NSUserDefaults standardUserDefaults] stringForKey:@"SettingsBlogUsername"];
        _password = [[NSUserDefaults standardUserDefaults] stringForKey:@"SettingsBlogPassword"];
        
        // Initializing media content
        _postTitle = [_mediaDetail valueForKey:@"name"];
        _tags   =  [_mediaDetail valueForKey:@"tags"];
        
        // Initializing metadata
        _latitude = [[_mediaDetail valueForKey:@"latitude"] floatValue];
        _longitude = [[_mediaDetail valueForKey:@"longitude"] floatValue];
        _captureDate = [_mediaDetail valueForKey:@"date"];
        
        // Loading and delegating webview
        [_webView loadRequest:requestObj];
        _webView.delegate = self;
        
        // Info on Post formats:
        // post-format-standard, post-format-aside, post-format-image, post-format-video
        // post-format-audio, post-format-quote, post-format-link, post-format-gallery
        switch (_mediaType) {
                
            case 1:
                _postFormat = @"post-format-image";
                _content =   [NSString stringWithFormat:
                              @"<img src=\"%@\" width=\"640\" height=\"480\">"
                              "<p><br>%@</p>",
                              [_mediaDetail valueForKey:@"webURL"], [_mediaDetail valueForKey:@"descriptor"]];
                break;
                
            case 2:
                _postFormat = @"post-format-video";
                _content = [NSString stringWithFormat:
                            @"[video mp4=\"%@\"]"
                            "<p><br>%@</p>",
                            [_mediaDetail valueForKey:@"webURL"], [_mediaDetail valueForKey:@"descriptor"]];
                break;
                
            case 3:
                _postFormat = @"post-format-audio";
                _content = [NSString stringWithFormat:
                            @"[audio m4a=\"%@\"]"
                            "<p><br>%@</p>",
                            [_mediaDetail valueForKey:@"webURL"], [_mediaDetail valueForKey:@"descriptor"]];
                break;
                
            default:
                _postFormat = @"post-format-standard";
                break;
        }
        
        // Knitting metadata from media details and appending to content
        NSString *metadata = [NSString stringWithFormat:@"<p>&nbsp;</p>[wp_gmaps lat=\"%f\" lng=\"%f\" zoom=\"9\" marker=\"1\"] <code>%@</code>",_latitude,_longitude,_captureDate];
        
        _content = [_content stringByAppendingString:metadata];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadButtonTapped:(UIBarButtonItem *)sender {
    
    // Injecting login details
    if( _login.length != 0 && _password.length != 0 ) {
        
        NSString*  setUsernameScript = [NSString  stringWithFormat:@"document.getElementById('user_login').value='%@';", _login];
        NSString*  setPasswordScript = [NSString stringWithFormat:@"document.getElementById('user_pass').value='%@';", _password];
        
        [_webView stringByEvaluatingJavaScriptFromString:setUsernameScript];
        [_webView stringByEvaluatingJavaScriptFromString:setPasswordScript];
    } else {
        UIAlertView *errorMessage = [[UIAlertView alloc]
                                     initWithTitle:@""
                                     message:@"Please set username and password in the settings or simply enter login details below!"
                                     delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:@"OK", nil];
        
        [errorMessage show];
    }
    
    // Injecting media to the input field in wordpress
    if(_tags != nil &&  _content != nil ) {
        
        NSString *clearTitlePlaceholderScript = [NSString stringWithFormat:@"document.getElementById('title-prompt-text').className='screen-reader-text';"];
        [_webView stringByEvaluatingJavaScriptFromString:clearTitlePlaceholderScript];
        
        NSString *setTitleScript = [NSString stringWithFormat: @"document.getElementById('title').value='%@';", _postTitle];
        [_webView stringByEvaluatingJavaScriptFromString:setTitleScript];
        
        NSString *setTagsScript = [NSString  stringWithFormat:@"document.getElementById('new-tag-post_tag').value='%@';", _tags];
        [_webView stringByEvaluatingJavaScriptFromString:setTagsScript];
        
        NSString *addTagButtonClickScript = [NSString stringWithFormat:@"document.getElementsByClassName('button tagadd')[0].click();"];
        [_webView stringByEvaluatingJavaScriptFromString:addTagButtonClickScript];
        
        NSString *setContent = [NSString stringWithFormat:@"document.getElementById('content').innerHTML = '%@'", _content];
        [_webView stringByEvaluatingJavaScriptFromString:setContent];
        
        NSString *setContentType = [NSString stringWithFormat:@"document.getElementById('%@').checked=true;", _postFormat];
        [_webView stringByEvaluatingJavaScriptFromString:setContentType];
    }
}

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertViewDelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 1000) {
        
        if (buttonIndex == 0) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }
}

@end
