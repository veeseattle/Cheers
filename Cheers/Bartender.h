//
//  Bartender.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bar.h"

@interface Bartender : NSObject

+(Bartender *)barInfoFromJSON:(NSData *)jsonData;

@property (strong,nonatomic) NSString *bartenderName;
@property (strong,nonatomic) UIImage *bartenderPicture;
@property (strong,nonatomic) Bar *bartendingAt;

@end