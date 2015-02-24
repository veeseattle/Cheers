//
//  Bar.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "Bar.h"

@implementation Bar


+(Bar *)barInfoFromJSON:(NSData *)jsonData {
  
  NSError *error;
  NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
  if (error) {
    NSLog(@"%@",error.localizedDescription);
    return nil;
  }
  
  //to change according to the JSON
  NSArray *items = [jsonDictionary objectForKey:@"items"];
  NSDictionary *myInfo = items.firstObject;
  
  Bar *bar = [[Bar alloc] init];
  bar.barName = myInfo[@"display_name"];

  return bar;
}


@end