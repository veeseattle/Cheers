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
@property (weak, nonatomic) IBOutlet UITextField *customDrinkField;
@property (strong, nonatomic) NSArray *drinksArray;
@property (weak, nonatomic) IBOutlet UIImageView *drinkPicture;

- (IBAction)drinkButton:(id)sender;

@end

@implementation OrderingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self.drinksPicker setUserInteractionEnabled:false];
  
  [[NetworkController sharedService] fetchDrinksForBar:@"Bar None" completionHandler:^(NSArray *results, NSString *error) {
   
    self.drinksArray = results;
    self.drinkValue = results.firstObject;
    self.drinksPicker.reloadAllComponents;
     [self.drinksPicker setUserInteractionEnabled:true];
    if (error) {
      //show alert view
    }}];
  
  //self.drinksArray  = [[NSArray alloc] initWithObjects:@" ", @"Gin & Tonic",@"Manhattan",@"Bud Light", nil];
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
//  [[NetworkController sharedService] fetchDrinkPicture:self.drinkValue completionHandler:^(UIImage *image) {
//  self.drinkPicture.image = image;
//  }];
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

- (IBAction)drinkButton:(id)sender {
  Order *order = [[Order alloc] init];
  order.customerID = @"BaconCheeseburger";
  order.drink = self.drinkValue;
  order.drink.drinkID = @"12345";
  
  [[NetworkController sharedService] postDrinkOrder:order];
    
  NSLog(@"Posted to the database");
  
}

@end
