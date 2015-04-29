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
#import "Drink.h"


@import PassKit;

@interface OrderingViewController () <UIPickerViewDelegate, UIPickerViewDataSource, PKPaymentAuthorizationViewControllerDelegate, STPCheckoutViewControllerDelegate>

@property (strong,nonatomic) NSArray *initialDrinksArray;
@property (strong, nonatomic) NSMutableArray *drinksArray;

- (IBAction)drinkButton:(id)sender;

@property (strong,nonatomic) NSArray *paymentNetwork;
@property (strong,nonatomic) NSString *applePayMerchantID;
@property (strong,nonatomic) PKPaymentSummaryItem *subtotal;
@property (strong,nonatomic) PKPaymentSummaryItem *total;

@property (nonatomic, strong) NSString *selectedDrink;
@property (weak, nonatomic) IBOutlet UILabel *drinkRecipe;
@property (weak, nonatomic) IBOutlet UIImageView *drinkPicture;

@property (weak, nonatomic) IBOutlet UIPickerView *drinkPickerView;

@end

@implementation OrderingViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.title = @"Bars";
  
  self.drinkPickerView.delegate = self;
  self.drinkPickerView.dataSource = self;
  
  
  //payment network setup
  self.paymentNetwork = [NSArray arrayWithObjects:PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, nil];
  self.applePayMerchantID = @"merchant.cheers";
  
  Drink *item1 = [[Drink alloc] init];
  item1.drinkID = @"1";
  item1.drinkName = @"Mimosa";
  item1.drinkPicture = @"http://www.google.com";
  item1.drinkRecipe = @"champagne, orange juice";
  Drink *item2 = [[Drink alloc] init];
  item2.drinkID = @"2";
  item2.drinkName = @"Bellini";
  item2.drinkPicture = @"http://www.google.com";
  item2.drinkRecipe = @"champagne, peach juice";
  Drink *item3 = [[Drink alloc] init];
  item3.drinkID = @"3";
  item3.drinkName = @"Gin and Tonic";
  item3.drinkPicture = @"http://www.google.com";
  item3.drinkRecipe = @"gin, tonic";
  
  self.drinksArray = [[NSMutableArray alloc] initWithArray:@[item1, item2, item3]];
  
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  Drink *drinkInPickerView = [[Drink alloc] init];
  drinkInPickerView = [self.drinksArray objectAtIndex:row];
  return drinkInPickerView.drinkName;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.drinksArray.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
  Drink *selectedDrink = [[Drink alloc] init];
  selectedDrink = [self.drinksArray objectAtIndex:row];
  self.drinkRecipe.text = selectedDrink.drinkRecipe;
  
}

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


//MARK: checkoutController - didFinish & didCreate
- (void) checkoutController:(STPCheckoutViewController *)controller didCreateToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
  
  //Hm, what to put here?
  
};

- (void) checkoutController:(STPCheckoutViewController *)controller didFinishWithStatus:(STPPaymentStatus)status error:(NSError *)error {
  
  
};



@end
