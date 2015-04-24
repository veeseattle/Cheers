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

@interface OrderingViewController : UIViewController

@property (strong, nonatomic) Drink *drinkValue;
@property (strong, nonatomic) NSString *barName;
@property (strong, nonatomic) Bar *bar;


+(void)showPickerViewInView: (UIView *)view
                withObjetcs: (NSArray *)objects
                withOptions: (NSDictionary *)options
    objectToStringConverter: (NSString *(^)(id object))converter
                 completion: (void(^)(id selectedObject))completion;
@end
