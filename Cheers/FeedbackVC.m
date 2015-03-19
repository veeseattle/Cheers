//
//  FeedbackVC.m
//  Cheers
//
//  Created by Vania Kurniawati on 3/19/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "FeedbackVC.h"

@interface FeedbackVC ()

@end

@implementation FeedbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
  
  NSString *fullURL = @"https://docs.google.com/forms/d/1Wz_BV9fBxbvg07IjNjQjR-KSJlCUtJm4KS6NMlzjjfo/viewform";
  NSURL *url = [NSURL URLWithString:fullURL];
  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
  [_webView loadRequest:requestObj];
    // Do any additional setup after loading the view.
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
