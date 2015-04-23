//
//  Bar.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "Bar.h"

@implementation Bar


+(NSMutableArray *)barInfoFromJSON:(NSData *)jsonData {
  
  NSError *error;
  NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
  
  if (error) {
    NSLog(@"%@",error.localizedDescription);
    return nil;
  }
 
  NSMutableArray *temp = [[NSMutableArray alloc] init];
  
  for (NSDictionary *item in jsonArray) {
  
  Bar *bar = [[Bar alloc] init];
  bar.barName = item[@"barName"];
  bar.barID = item[@"_id"];
    
  }
  
  return temp;
}


@end