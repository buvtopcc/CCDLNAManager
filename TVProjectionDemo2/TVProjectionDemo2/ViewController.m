//
//  ViewController.m
//  TVProjectionDemo2
//
//  Created by pengchangcheng on 2020/3/2.
//  Copyright © 2020 hustcc. All rights reserved.
//

#import "ViewController.h"
#import "CCDLNADeviceSearchView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 80, 80, 80)];
    button.backgroundColor = [UIColor orangeColor];
    [button setTitle:@"TV" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onTV) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
                        
- (void)onTV
{
    NSLog(@"onTV");
    [CCDLNADeviceSearchView showInSuperView:[[UIApplication sharedApplication].windows firstObject]];
}


@end
