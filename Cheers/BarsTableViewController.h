//
//  BarsTableViewController.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/25/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bar.h"
#import "BarCell.h"
#import "OrderingViewController.h"
#import "CustomerSignupViewController.h"
#import "AppDelegate.h"
#import "NetworkController.h"

@interface BarsTableViewController : UITableViewController

@property (strong, nonatomic) NSString *barName;


@end
