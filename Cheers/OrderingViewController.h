//
//  OrderingViewController.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Drink.h"
#import "BarsTableViewController.h"

@interface OrderingViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) Drink *drinkValue;
@property (strong, nonatomic) NSString *barName;


@end
