//
//  Order.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "Order.h"

@implementation Order

+(NSArray *)orderFromJSON:(NSData *)jsonData {
  
  NSError *error;
  NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
  if (error) {
    NSLog(@"%@",error.localizedDescription);
    return nil;
  }
  
  NSMutableArray *temp = [[NSMutableArray alloc] init];
  
  for (NSDictionary *item in jsonArray) {
    Order *order = [[Order alloc] init];
    order.orderID = item[@"_id"];
    order.customerID = item[@"customerID"];
    order.drink = item[@"drinkID"];
    order.drinkID = item[@"drinkID"];
    order.customerPicture = item[@"customerPicture"];
    
    [temp addObject:order];
  }
  NSArray *final = [[NSArray alloc] initWithArray:temp];
  return final;
}



@end