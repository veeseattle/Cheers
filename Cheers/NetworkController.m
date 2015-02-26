//
//  NetworkController.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/24/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "NetworkController.h"
#import "Drink.h"
#import "Order.h"

@interface NetworkController ()

@end

@implementation NetworkController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


+(id)sharedService {
  
  static NetworkController *mySharedService;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mySharedService = [[NetworkController alloc] init];
  });
  return mySharedService;
}



//MARK: FetchAvailableDrinks
-(void)fetchDrinksForBar:(NSString *)searchTerm completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler {
  
  
  NSString *urlString = @"http://localhost:3000/api/v1/cheers/drink";
 
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"GET";
  
  NSURLSession *session = [NSURLSession sharedSession];
  
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      completionHandler(nil,@"Could not connect");
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger statusCode = httpResponse.statusCode;
      
      switch (statusCode) {
        case 200 ... 299: {
          NSLog(@"%ld",(long)statusCode);
          NSArray *results = [Drink drinkFromJSON:data];
          
          dispatch_async(dispatch_get_main_queue(), ^{
            if (results) {
              completionHandler(results,nil);
            } else {
              completionHandler(nil,@"Search could not be completed");
            }
          });
          break;
        }
        default:
          NSLog(@"%ld",(long)statusCode);
          break;
      }
      
    }
  }];
  [dataTask resume];
}


//MARK: FetchOrders
-(void)fetchOrdersForBar:(NSString *)searchTerm completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler {
  
  
  NSString *urlString = @"http://localhost:3000/api/v1/cheers/drinkorder";
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"GET";
  
  NSURLSession *session = [NSURLSession sharedSession];
  
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      completionHandler(nil,@"Could not connect");
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger statusCode = httpResponse.statusCode;
      
      switch (statusCode) {
        case 200 ... 299: {
          NSLog(@"%ld",(long)statusCode);
          NSArray *results = [Order orderFromJSON:data];
          
          dispatch_async(dispatch_get_main_queue(), ^{
            if (results) {
              completionHandler(results,nil);
            } else {
              completionHandler(nil,@"Search could not be completed");
            }
          });
          break;
        }
        default:
          NSLog(@"%ld",(long)statusCode);
          break;
      }
      
    }
  }];
  [dataTask resume];
}


//MARK: FetchPictureOfDrink
-(void)fetchDrinkPicture:(NSString *)drinkPicture completionHandler:(void (^) (UIImage *image))completionHandler {
  
  dispatch_queue_t imageQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
  dispatch_async(dispatch_get_main_queue(), ^{
    NSURL *url = [NSURL URLWithString:drinkPicture];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      completionHandler(image);
    });
  });
}

//MARK: PostDrinkOrder
-(void)postDrinkOrder:(Order *)order {
  
  NSString *urlString = @"http://localhost:3000/api/v1/cheers/drinkorder";
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"POST";
  
  NSDate *now = [NSDate date];
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setDateFormat:@"HH:mm:ss"];
  NSString *newDateString = [outputFormatter stringFromDate:now];
  
  NSDictionary *drinkOrder = @{@"drinkID" : order.drink.drinkID};

  NSString *post = [NSString stringWithFormat:@"%@",drinkOrder];
  
  NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
  
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:drinkOrder options:0 error:&error];
  NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  request.HTTPBody = data;
  
  NSURLSession *session = [NSURLSession sharedSession];
  
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
    }
    else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger statusCode = httpResponse.statusCode;
      
      switch (statusCode) {
        case 200 ... 299: {
          NSLog(@"%ld",(long)statusCode);
        break;
        }
        default:
          NSLog(@"%ld",(long)statusCode);
          break;
      }
    }
  }];
  [dataTask resume];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
