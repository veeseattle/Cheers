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
@property (strong,nonatomic) NSString *emailAddress;
@property (strong,nonatomic) NSString *password;
@property (strong,nonatomic) UIImage *image;
@property (strong,nonatomic) NSString *promoCode;

@end