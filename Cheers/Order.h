//
//  Order.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Customer.h"
#import "Drink.h"

@interface Order : NSObject

@property (strong,nonatomic) Customer *customer;
@property (strong,nonatomic) NSString *customerID;
@property (strong,nonatomic) Drink *drink;


@end