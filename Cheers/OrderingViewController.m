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
  
  self.paymentNetwork = [NSArray arrayWithObjects:PKPaymentNetworkAmex, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa, nil];
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
    self.drinkPicture.image = image;
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}



//MARK: Drink button
//Submit drink order/pay with Apple Pay button setup & action
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
    
    STPTestPaymentAuthorizationViewController *paymentController = [[STPTestPaymentAuthorizationViewController alloc]
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
  NSURL *url = [NSURL URLWithString:@"https://example.com/token"];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"POST";
  NSString *body     = [NSString stringWithFormat:@"stripeToken=%@", token.tokenId];
  request.HTTPBody   = [body dataUsingEncoding:NSUTF8StringEncoding];
  
  [NSURLConnection sendAsynchronousRequest:request
                                     queue:[NSOperationQueue mainQueue]
                         completionHandler:^(NSURLResponse *response,
                                             NSData *data,
                                             NSError *error) {
                           if (error) {
                             completion(PKPaymentAuthorizationStatusFailure);
                           } else {
                             completion(PKPaymentAuthorizationStatusSuccess);
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
