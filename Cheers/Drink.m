//
//  Drink.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "Drink.h"

@implementation Drink

+(NSArray *)drinkFromJSON:(NSData *)jsonData {
  
  NSError *error;
  NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
  if (error) {
    NSLog(@"%@",error.localizedDescription);
    return nil;
  }

  NSMutableArray *temp = [[NSMutableArray alloc] init];
  
  for (NSDictionary *item in jsonArray) {
    Drink *drink = [[Drink alloc] init];
    NSLog(drink.drinkName);
    drink.drinkName = item[@"drinkName"];
    drink.drinkID = item[@"drinkID"];
    drink.drinkPicture = item[@"drinkPicture"];
    drink.drinkRecipe = item[@"drinkRecipe"];
    
    [temp addObject:drink];
  }
  NSArray *final = [[NSArray alloc] initWithArray:temp];
  return final;
}


@end
