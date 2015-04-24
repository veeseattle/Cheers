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
#import "Stripe.h"
#import "STPTestPaymentAuthorizationViewController.h"
#import "MMPickerView.h"
#import "Drink.h"
#import "DrinkToOrderCell.h"

@import PassKit;

@interface OrderingViewController () <UITableViewDelegate, UITableViewDataSource, PKPaymentAuthorizationViewControllerDelegate, STPCheckoutViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *orderTable;

@property (strong,nonatomic) NSArray *initialDrinksArray;
@property (strong, nonatomic) NSMutableArray *drinksArray;
@property (weak, nonatomic) IBOutlet UILabel *recipe;

- (IBAction)drinkButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *drinkPicture;

@property (strong,nonatomic) NSArray *paymentNetwork;
@property (strong,nonatomic) NSString *applePayMerchantID;
@property (strong,nonatomic) PKPaymentSummaryItem *subtotal;
@property (strong,nonatomic) PKPaymentSummaryItem *total;

@property (strong,nonatomic) MMPickerView *drinkPickerView;
@property (strong,nonatomic) UIView *drinkChoiceView;
@property (nonatomic, strong) NSString *selectedDrink;

@end

@implementation OrderingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = @"Bars";
  
  self.drinkPickerView = [[MMPickerView alloc] init];
  
  //payment network setup
  self.paymentNetwork = [NSArray arrayWithObjects:PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, nil];
  self.applePayMerchantID = @"merchant.cheers";
  
  self.drinkPicture.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.drinkPicture.layer.cornerRadius = 25;
  self.drinkPicture.clipsToBounds = true;
  
  self.orderTable.delegate = self;
  self.orderTable.dataSource = self;
  
  
}

#pragma mark - orderTable Delegate Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UINib *cellNib = [UINib nibWithNibName:@"DrinkInCartCell" bundle:nil];
  [tableView registerNib:cellNib forCellReuseIdentifier:@"DRINK_TO_ORDER_CELL"];
  
  DrinkToOrderCell *drinkCell = [tableView dequeueReusableCellWithIdentifier:@"DRINK_TO_ORDER_CELL" forIndexPath:indexPath];
  
  drinkCell.drinkName.text = @"Tap to add a drink";
  drinkCell.drinkPrice.text = @" ";
  
  return drinkCell;
}

-(NSString *) objectToStringConverter:(Drink *)drinkObject {
  
  NSString *drinkName = drinkObject.drinkName;
  return drinkName;
  
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [[NetworkController sharedService] fetchDrinksForBar:self.bar.barID completionHandler:^(NSArray *results, NSString *error) {
    
    NSMutableArray *drinksArray = [[NSMutableArray alloc] init];
    self.drinkValue = results.firstObject;
    self.selectedDrink = results.firstObject;
    
    NSMutableDictionary *drinksDictionary = [[NSMutableDictionary alloc] init];
    
    //create dictionary with key: drink name, value: drinkID from drin
    
    
    //create string array containing all the drink names
    for (Drink *item in results) {
      NSString *drinkName = item.drinkName;
      NSString *drinkID = item.drinkID;
      //[drinksDictionary setObject:drinkID forKey:drinkName];
       [drinksArray addObject:drinkName];
    }
    
//    [MMPickerView showPickerViewInView:self.view withObjects:results withOptions:nil objectToStringConverter:^NSString *(id object) {
//      NSString *selectedDrinkName = [self objectToStringConverter:object];
//      return selectedDrinkName;
//      
//    } completion:^(id selectedObject) {
//      //self.selectedDrink = selectedString;
//      
//      //NSString *selectedDrinkID = [drinksDictionary objectForKey:selectedString];
//      
//      Drink *selectedDrink = (Drink *)selectedObject;
//      
//      DrinkToOrderCell *cell = (DrinkToOrderCell *)[tableView cellForRowAtIndexPath:indexPath];
//      cell.drinkName.text = selectedDrink.drinkName;
//      cell.drinkPrice.text = [NSString stringWithFormat: @"%ld", (long)selectedDrink.drinkPrice];
//      
//
//    }];
    
    [MMPickerView showPickerViewInView:self.view
                           withStrings:drinksArray
                           withOptions:nil
//  @{MMbackgroundColor: [UIColor blackColor],
//                                         MMtextColor: [UIColor whiteColor],
//                                         MMtoolbarColor: [UIColor blackColor],
//                                         MMbuttonColor: [UIColor whiteColor],
//                                         MMfont: [UIFont systemFontOfSize:18],
//                                         MMvalueY: @3}
//     
                            completion:^(NSString *selectedString) {
                              self.selectedDrink = selectedString;
                              
                              //NSString *selectedDrinkID = [drinksDictionary objectForKey:selectedString];
                              
                              
                              DrinkToOrderCell *cell = (DrinkToOrderCell *)[tableView cellForRowAtIndexPath:indexPath];
                              cell.drinkName.text = selectedString;
                              cell.drinkPrice.text = @"$9";
                              
                              
                            }];
    
    if (error) {
      [[[UIAlertView alloc] initWithTitle:@"Unable to Connect" message:@"There was a connection error. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }}];
  
  
  
}


//
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//  Drink *drink = self.drinksArray[row];
//  return drink.drinkName;
//}
//
//- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//  self.drinkValue = [self.drinksArray objectAtIndex:[self.drinksPicker selectedRowInComponent:component ]];
//  Drink *drink = self.drinkValue;
//  self.recipe.text = drink.drinkRecipe;
//
//  [[NetworkController sharedService] fetchDrinkPicture:drink.drinkPicture completionHandler:^(UIImage *image) {
//    self.drinkPicture.image = image;
//  }];
//}


//MARK: Drink button
- (IBAction)drinkButton:(id)sender {
  Order *order = [[Order alloc] init];
  order.drink = self.drinkValue;
  NSString *drinkID = order.drink.drinkID;
  
  [[NetworkController sharedService] postDrinkOrder:drinkID];
  
  //create simple PKPaymentRequest object that represents a single Apple Pay payment
  PKPaymentRequest *request = [Stripe paymentRequestWithMerchantIdentifier:self.applePayMerchantID];
  
  //setup for transaction capabilities
  request.merchantIdentifier = self.applePayMerchantID;
  request.supportedNetworks = self.paymentNetwork;
  request.merchantCapabilities = PKMerchantCapability3DS;
  request.countryCode = @"US";
  request.currencyCode = @"USD";
  
  //setup for payment summary
  NSDecimalNumber *subtotalAmount = [NSDecimalNumber decimalNumberWithMantissa:600 exponent:-2 isNegative:NO]; //replace 6 with actual drink price
  self.subtotal = [PKPaymentSummaryItem summaryItemWithLabel:@"Subtotal" amount:subtotalAmount];
  
  NSDecimalNumber *totalAmount = [NSDecimalNumber zero];
  totalAmount = [totalAmount decimalNumberByAdding:subtotalAmount];
  self.total = [PKPaymentSummaryItem summaryItemWithLabel:@"Unicorn - Capitol Hill" amount:totalAmount]; //replace Unicorn - Capitol Hill with actual bar name
  
  request.paymentSummaryItems = [NSArray arrayWithObjects:self.subtotal, self.total, nil];
  
  if ([Stripe canSubmitPaymentRequest:request]) {
    
    
    PKPaymentAuthorizationViewController *paymentController = [[PKPaymentAuthorizationViewController alloc]
                                                               initWithPaymentRequest:request];
    paymentController.delegate = self;
    
    [self presentViewController:paymentController animated:YES completion:nil];
    
  }
  else {
    
  };
  
  //  PKPaymentAuthorizationViewController *applePayController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
  //
  //  [self presentViewController:applePayController animated:true completion:nil];
  //
  
  NSLog(@"Posted to the database");
  
}

// MARK: - PKPaymentAuthorizationViewControllerDelegate

- (void) paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
  //use Stripe SDK to finish charging customer
  controller.delegate = self;
  [self handlePaymentAuthorizationWithPayment:payment completion:completion];
  
  //when this is done, call completion(PKPaymentAuthorizationStatus.Success)
};

- (void) paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
  [controller dismissViewControllerAnimated:true completion:nil];
};

//this creates the stripe token
- (void)handlePaymentAuthorizationWithPayment:(PKPayment *)payment
                                   completion:(void (^)(PKPaymentAuthorizationStatus))completion {
  [[STPAPIClient sharedClient] createTokenWithPayment:payment
                                           completion:^(STPToken *token, NSError *error) {
                                             if (error) {
                                               completion(PKPaymentAuthorizationStatusFailure);
                                               return;
                                             }
                                             /*
                                              We'll implement this below in "Sending the token to your server".
                                              Notice that we're passing the completion block through.
                                              See the above comment in didAuthorizePayment to learn why.
                                              */
                                             [self createBackendChargeWithToken:token completion:completion];
                                           }];
}


- (void)createBackendChargeWithToken:(STPToken *)token
                          completion:(void (^)(PKPaymentAuthorizationStatus))completion {
  NSURL *url = [NSURL URLWithString:@"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/drinkorder"];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  
  //get our javascript server's token, put it in header
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *ourServersToken = [userDefaults objectForKey:@"token"];
  [request setValue:ourServersToken forHTTPHeaderField:@"eat"];
  
  //request body is the stripe token
  request.HTTPMethod = @"POST";
  NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
  request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
  
  //javascript post requirement
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response,
                                             NSData *data,
                                             NSError *error) {
                           if (error) {
                             completion(PKPaymentAuthorizationStatusFailure);
                             NSLog(@"oopsie, that failed!");
                           } else {
                             completion(PKPaymentAuthorizationStatusSuccess);
                             NSLog(@"ok, that worked!");
                           }
                         }];
}

#pragma showPickerView
+(void)showPickerViewInView:(UIView *)view withObjetcs:(NSArray *)objects withOptions:(NSDictionary *)options objectToStringConverter:(NSString *(^)(id))converter completion:(void (^)(id))completion {
  
}

//MARK: checkoutController - didFinish & didCreate
- (void) checkoutController:(STPCheckoutViewController *)controller didCreateToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
  
  //Hm, what to put here?
  
};

- (void) checkoutController:(STPCheckoutViewController *)controller didFinishWithStatus:(STPPaymentStatus)status error:(NSError *)error {
  
  
};



@end
