//
//  Drink.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Drink : NSObject

+(NSArray *)drinkFromJSON:(NSData *)jsonData;

@property (strong,nonatomic) NSString *drinkID; //this is the system-defined ID assigned by Mongo
@property (strong,nonatomic) NSString *drinkName;
@property (strong,nonatomic) NSString *drinkRecipe;
@property (assign) NSInteger *drinkPrice;
@property (strong,nonatomic) UIImage *drinkPicture;


@end