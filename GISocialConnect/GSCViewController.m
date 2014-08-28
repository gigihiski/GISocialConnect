//
//  GSCViewController.m
//  GISocialConnect
//
//  Created by Gigih Iski Prasetyawan on 7/11/14.
//  Copyright (c) 2014 Etsuri Ltd. All rights reserved.
//

#import "GSCViewController.h"

#import "GISocialConnect.h"

@interface GSCViewController () <GISocialConnectDelegate>

@end

@implementation GSCViewController{
    GISocialConnect *socialConnect;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // init GISocialConnect
    socialConnect = [[GISocialConnect alloc] init];
    socialConnect.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (IBAction)facebookAction:(id)sender {
    [socialConnect facebookAuth];
}

- (IBAction)twitterAction:(id)sender {
    [socialConnect twitterAuth];
}

#pragma mark - GISocialConnect Delegate

- (void) socialRequest:(id)response socialType:(NSString *)socialType error:(NSError *)error {
    NSLog(@"social type : %@", socialType);
    NSLog(@"response : %@", response);
    
}

- (void) socialRequestFailed:(NSString *)message socialType:(NSString *)socialType error:(NSError *)error {
    NSLog(@"error : %@", message);
}

@end
