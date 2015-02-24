//
//  Customer.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Customer : NSObject

@property (strong,nonatomic) NSString *name;
@property (strong,nonatomic) NSString *birthday;
@property (assign) NSInteger *age;
@property (strong,nonatomic) UIImage *image;


@end