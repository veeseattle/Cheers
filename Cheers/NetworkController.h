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

@property NSUserDefaults *userDefaults;

+(id)sharedService;

-(void)createNewUser:(NSDictionary *)User completionHandler:(void (^)(NSString *results, NSString *error))completionHandler;

-(void)fetchDrinksForBar:(NSString *)searchTerm completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler;

-(void)fetchDrinkPicture:(NSString *)drinkPicture completionHandler:(void (^) (UIImage *image))completionHandler;

-(void)fetchAvailableBars:(NSString *)city completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler;

-(void)fetchOrdersForBar: (NSString *)searchTerm completionHandler:(void (^)(NSMutableArray * results, NSString *error))completionHandler;

-(void)postDrinkOrder:(NSString *)drinkID;

-(void)putDrinkCompletion:(NSString *)deletedID completionHandler:(void (^)(NSString *results, NSString *error))completionHandler;

-(void)putDrinkOrderToInProgress:(NSString *)drinkOrderID completionHandler:(void (^)(NSString *results, NSString *error))completionHandler;



@end
