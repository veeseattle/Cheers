//
//  OrderingViewController.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "OrderingViewController.h"
#import "BartenderViewController.h"
#import "NetworkController.h"
#import "Order.h"

@interface OrderingViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *drinksPicker;
@property (strong, nonatomic) NSArray *drinksArray;
@property (weak, nonatomic) IBOutlet UILabel *recipe;

- (IBAction)drinkButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *myPicture;
@property (weak, nonatomic) IBOutlet UIImageView *drinkPicture;

@end

@implementation OrderingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = @"Bars";
  
  //user profile picture
  self.myPicture.image = [UIImage imageNamed:@"juju.jpg"];
  self.myPicture.layer.borderWidth = 6;
  self.myPicture.layer.cornerRadius = 50;
  self.myPicture.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.myPicture.clipsToBounds = true;
  
  self.drinkPicture.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.drinkPicture.layer.cornerRadius = 25;
  self.drinkPicture.clipsToBounds = true;
  
  [self.drinksPicker setUserInteractionEnabled:false];
  
  
  [[NetworkController sharedService] fetchDrinksForBar:@"Stout - Capitol Hill" completionHandler:^(NSArray *results, NSString *error) {
    
    self.drinksArray = results;
    self.drinkValue = results.firstObject;
    self.drinksPicker.reloadAllComponents;
    [self.drinksPicker setUserInteractionEnabled:true];
    if (error) {
      //show alert view
    }}];
  
  self.drinksPicker.delegate = self;
  self.drinksPicker.dataSource = self;
  // Do any additional setup after loading the view.
}


//MARK: UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
  return self.drinksArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  Drink *drink = self.drinksArray[row];
  return drink.drinkName;
  
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  NSLog(@"%ld",(long)row);
  self.drinkValue = [self.drinksArray objectAtIndex:[self.drinksPicker selectedRowInComponent:component ]];
  Drink *drink = self.drinkValue;
  self.recipe.text = drink.drinkRecipe;
  
  [[NetworkController sharedService] fetchDrinkPicture:drink.drinkPicture completionHandler:^(UIImage *image) {
    
  self.drinkPicture.image = image;
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  if ([segue.identifier isEqualToString:@"SUBMIT_ORDER"]) {
//    BartenderViewController *destinationVC = (BartenderViewController *)segue.destinationViewController;
//    if (!self.drinkValue.length == 0) {
//      destinationVC.drinkName = self.drinkValue;
//    }
//    else {
//      destinationVC.drinkName = [self.customDrinkField text];
//    }
//
//  }
//}

//Drink Button setup
- (IBAction)drinkButton:(id)sender {
  Order *order = [[Order alloc] init];
  order.drink = self.drinkValue;
  NSString *drinkID = order.drink.drinkID;
  
  [[NetworkController sharedService] postDrinkOrder:drinkID];
  
  UIAlertController *orderSubmitted = [UIAlertController alertControllerWithTitle:@"Order Submitted" message:@"Your drink order has been sent to the bar and should be ready soon!" preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Cool" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    [orderSubmitted dismissViewControllerAnimated:YES completion:nil];
  }];
  
  [orderSubmitted addAction:ok];
  
  NSLog(@"Posted to the database");
  
}

@end
