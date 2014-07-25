//
//  ACEMediaTabViewController.m
//  arc
//
//  Created by Shree Raj Shrestha on 7/24/14.
//  Copyright (c) 2014 Shree Raj Shrestha. All rights reserved.
//

#import "ACEMediaTabViewController.h"

@interface ACEMediaTabViewController ()

@end

@implementation ACEMediaTabViewController

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configuring the tab bar
    UITabBar *tabBar = self.tabBar;
    tabBar.barStyle = UIBarStyleBlack;
    tabBar.barTintColor = [UIColor whiteColor];
    tabBar.itemPositioning = UITabBarItemPositioningCentered;
    
    // Customizing the tab bar items
    UITabBarItem *imgItem = [tabBar.items objectAtIndex:0];
    UITabBarItem *vidItem = [tabBar.items objectAtIndex:1];
    UITabBarItem *recItem = [tabBar.items objectAtIndex:2];
    imgItem.image = [UIImage imageNamed:@"imgTab.png"];
    vidItem.image = [UIImage imageNamed:@"vidTab.png"];
    recItem.image = [UIImage imageNamed:@"recTab.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
