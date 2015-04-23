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


@import PassKit;

@interface OrderingViewController () <PKPaymentAuthorizationViewControllerDelegate, STPCheckoutViewControllerDelegate>

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
  
  self.navigationItem.title = @"Bars";
  
  //payment network setup
  self.paymentNetwork = [NSArray arrayWithObjects:PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, nil];
  self.applePayMerchantID = @"merchant.cheers";
  
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
  
  [[NetworkController sharedService] fetchDrinksForBar:self.bar.barID completionHandler:^(NSArray *results, NSString *error) {
    
    self.drinksArray = results;
    self.drinkValue = results.firstObject;
    [self.drinksPicker reloadAllComponents];
    [self.drinksPicker setUserInteractionEnabled:true];
    if (error) {
        [[[UIAlertView alloc] initWithTitle:@"Unable to Connect" message:@"There was a connection error. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }}];
  
  self.drinksPicker.delegate = self;
  self.drinksPicker.dataSource = self;
  
}



#pragma mark UIPickerView
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
  self.drinkValue = [self.drinksArray objectAtIndex:[self.drinksPicker selectedRowInComponent:component ]];
  Drink *drink = self.drinkValue;
  self.recipe.text = drink.drinkRecipe;
  
  [[NetworkController sharedService] fetchDrinkPicture:drink.drinkPicture completionHandler:^(UIImage *image) {
    self.drinkPicture.image = image;
  }];
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
