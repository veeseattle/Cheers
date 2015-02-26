//
//  NetworkController.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/24/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Drink.h"
#import "Order.h"

@interface NetworkController : UIViewController

+(id)sharedService;

-(void)fetchDrinksForBar:(NSString *)searchTerm completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler;

-(void)fetchDrinkPicture:(NSString *)drinkPicture completionHandler:(void (^) (UIImage *image))completionHandler;

-(void)fetchOrdersForBar: (NSString *)searchTerm completionHandler:(void (^)(NSArray * results, NSString *error))completionHandler;

-(void)postDrinkOrder:(Order *)order;



@end
