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
    drink.drinkName = item[@"drinkName"];
    drink.drinkID = item[@"_id"];
    drink.drinkPicture = item[@"drinkPicture"];
    
    NSArray *drinkRecipeArray = item[@"drinkRecipe"];
    
    drink.drinkRecipe = [drinkRecipeArray componentsJoinedByString:@","];
    
    [temp addObject:drink];
  }
  NSArray *final = [[NSArray alloc] initWithArray:temp];
  return final;
}


@end
