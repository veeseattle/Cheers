//
//  DrinkOrderCell.h
//  Cheers
//
//  Created by Vania Kurniawati on 2/24/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinkOrderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *customerPicture;
@property (weak, nonatomic) IBOutlet UILabel *drinkName;
@property (weak, nonatomic) IBOutlet UILabel *customerName;
@property (weak, nonatomic) IBOutlet UISwitch *makeDrink;

@end
