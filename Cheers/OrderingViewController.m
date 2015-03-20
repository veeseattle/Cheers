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
@import PassKit;

@interface OrderingViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *drinksPicker;
@property (strong, nonatomic) NSArray *drinksArray;
@property (weak, nonatomic) IBOutlet UILabel *recipe;

- (IBAction)drinkButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIImageView *myPicture;
@property (weak, nonatomic) IBOutlet UIImageView *drinkPicture;
@property (strong,nonatomic) NSArray *paymentNetwork;
@property (strong,nonatomic) NSString *applePayMerchantID;
@property (strong,nonatomic) PKPaymentSummaryItem *subtotal;
@property (strong,nonatomic) PKPaymentSummaryItem *total;

@end

@implementation OrderingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.paymentNetwork = (PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa);
  self.applePayMerchantID = @"merchant.cheers";
  
  self.navigationItem.title = @"Bars";
  
  //user profile picture
  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  
  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"MyPicture.jpg"];
  
  
  UIImage *userPicture = [[UIImage alloc] initWithContentsOfFile:filePath];
  
  self.myPicture.image = userPicture;
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
    NSLog(drink.drinkPicture);
    self.drinkPicture.image = image;
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}



//Submit drink order/pay with Apple Pay button setup & action
- (IBAction)drinkButton:(id)sender {
  Order *order = [[Order alloc] init];
  order.drink = self.drinkValue;
  NSString *drinkID = order.drink.drinkID;
  
  [[NetworkController sharedService] postDrinkOrder:drinkID];
  
  //create simple PKPaymentRequest object that represents a single Apple Pay payment
  PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
  PKPaymentAuthorizationViewController *applePayController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
  [self presentViewController:applePayController animated:true completion:nil];
  
  //setup for transaction capabilities
  request.merchantIdentifier = self.applePayMerchantID;
  request.supportedNetworks = self.paymentNetwork;
  request.merchantCapabilities = PKMerchantCapability3DS;
  request.countryCode = @"US";
  request.currencyCode = @"USD";
  
  //setup for payment summary
  NSDecimalNumber *subtotalAmount = [NSDecimalNumber decimalNumberWithMantissa:6 exponent:-2 isNegative:NO]; //replace 6 with actual drink price
  self.subtotal = [PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal" amount:subtotalAmount];
  
  NSDecimalNumber *totalAmount = [NSDecimalNumber zero];
  totalAmount = [totalAmount decimalNumberByAdding:subtotalAmount];
  self.total = [PKPaymentSummaryItem summaryItemWithLabel:@"Unicorn - Capitol Hill" amount:totalAmount]; //replace Unicorn - Capitol Hill with actual bar name
  
  request.paymentSummaryItems = @[self.subtotal, self.total];
  
  
  
  
  NSLog(@"Posted to the database");
  
}

@end
