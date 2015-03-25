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

+(NSMutableArray *)orderFromJSON:(NSData *)jsonData;

@property (strong,nonatomic) NSString *orderID;
@property (strong,nonatomic) NSString *customer;
@property (strong,nonatomic) NSString *customerID;
@property (strong,nonatomic) Drink *drink;
@property (strong,nonatomic) NSString *drinkName;
@property (strong,nonatomic) NSString *drinkID;
@property (strong,nonatomic) NSString *customerPicture;
@property (strong,nonatomic) NSString *status;
@property (strong,nonatomic) NSNumber *orderInProgress;
@property (strong,nonatomic) NSNumber *orderInQueue;



@end