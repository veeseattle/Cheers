//
//  Bar.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Bar : NSObject

+(Bar *)barInfoFromJSON:(NSData *)jsonData;

@property (strong,nonatomic) NSString *barName;
@property (strong,nonatomic) NSString *location;
@property (strong,nonatomic) UIImage *image;


@end