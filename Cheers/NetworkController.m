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
#import "Bar.h"

@interface NetworkController ()
@property (strong,nonatomic) NSString *token;
@property (strong,nonatomic) NSString *baseURL;
@end

@implementation NetworkController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.baseURL = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/";
  
  
}

-(void)getMyToken {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *token = [userDefaults objectForKey:@"token"];
  self.token = token;
}

- (void) setUpGETNetworkCall: (NSString *)urlPath completionHandler:(void (^)(NSMutableURLRequest *request))completionHandler {
  
  [self getMyToken];
  NSString *token = self.token;
  
  NSString *urlString = urlPath;
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"GET";
  [request setValue:token forHTTPHeaderField:@"eat"];
  
  completionHandler(request);
  
}


+(id)sharedService {
  
  static NetworkController *mySharedService;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mySharedService = [[NetworkController alloc] init];
  });
  return mySharedService;
}


#pragma mark - createNewUser and save token to NSUserDefault
-(void)createNewUser:(NSDictionary *)User completionHandler:(void (^)(NSString *results, NSString *error))completionHandler {
  
  NSString *authURL = @"https://cheers-bartender-app.herokuapp.com/api/v1/create_user";
  NSURL *url = [NSURL URLWithString:authURL];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url];
  
  NSDictionary *customer = User;
  
  //HTTPHeaderField Properties
  NSString *post = [NSString stringWithFormat:@"%@",customer];
  NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
  
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:customer options:0 error:&error];
  
  request.HTTPBody = data;
  request.HTTPMethod = @"POST";
  
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSError *responseError;
    
    NSDictionary *tokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&responseError];
    NSString *token = tokenResponse[@"eat"];
    NSLog(@"%@", token);
    
    if (error) {
      completionHandler(nil, @"could not complete task");
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger statusCode = httpResponse.statusCode;
      NSLog(@"statusCode %ld", (long)statusCode);
      
      //Save token to NSUserDefaults
      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
      [userDefaults setObject:token forKey:@"token"];
      [userDefaults synchronize];
      completionHandler(nil,nil);
      
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      
      
    });
  }];
  [dataTask resume];
}


#pragma mark - fetchAvailableBars
- (void) fetchAvailableBars:(NSString *)city completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler {
  
  NSString *urlString = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/bars";
  [self setUpGETNetworkCall:urlString completionHandler:^(NSMutableURLRequest *request) {
  
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        completionHandler(nil,@"Unable to connect");
      } else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpResponse.statusCode;
        
        switch (statusCode) {
          case 200 ... 299: {
            NSLog(@"%ld",(long)statusCode);
            NSMutableArray *results = [Bar barInfoFromJSON:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
              if (results) {
                completionHandler(results,nil);
                }
              else {
                
                completionHandler(nil, @"Cannot get list of bars");
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
  }];
  
}

//MARK: FetchAvailableDrinks -- will return id, name, recipe, and picture
-(void)fetchDrinksForBar:(NSString *)searchTerm completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler {
  
  NSString *urlString = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/bars/55385a31554fa50300b89008/drinks";
  
  [self setUpGETNetworkCall:urlString completionHandler:^(NSMutableURLRequest *request) {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      if (error) {
        completionHandler(nil,@"Unable to connect");
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
  }];
}

//MARK: FetchDrinkOrders
-(void)fetchOrdersForBar:(NSString *)searchTerm completionHandler:(void (^)(NSMutableArray *results, NSString *error))completionHandler {
  
  
  NSString *urlString = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/drinkorder";
  
  [self setUpGETNetworkCall:urlString completionHandler:^(NSMutableURLRequest *request) {
    
    
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
            NSMutableArray *results = [Order orderFromJSON:data];
            
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
  }];
}


//MARK: FetchPicture
-(void)fetchDrinkPicture:(NSString *)picture completionHandler:(void (^) (UIImage *image))completionHandler {
  
  dispatch_queue_t imageQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
  dispatch_async(imageQueue, ^{
    NSURL *url = [NSURL URLWithString:picture];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      completionHandler(image);
    });
  });
}

//MARK: PostDrinkOrder (pass in token, drinkID)
-(void)postDrinkOrder:(NSString *)drinkID {
  
  //token, url, all that good stuff
  [self getMyToken];
  NSString *token = self.token;
  NSString *urlString = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/drinkorder";
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  
  //we are posting!
  request.HTTPMethod = @"POST";
  
  [request setValue:token forHTTPHeaderField:@"eat"];
  
  NSError *error;
  NSDictionary *drinkOrder = @{@"drinkID" : drinkID};
  NSString *post = [NSString stringWithFormat:@"%@",drinkOrder];
  
  NSData *data = [NSJSONSerialization dataWithJSONObject:drinkOrder options:0 error:&error];
  
  NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
  
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
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

//MARK: CompleteDrinkOrder
-(void)putDrinkCompletion:(NSString *)deletedID completionHandler:(void (^)(NSString *results, NSString *error))completionHandler {
  
  [self getMyToken];
  NSString *token = self.token;
  NSString *orderID = deletedID;
  NSString *baseURL = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/drinkorder/completed/";
  NSString *urlString = [baseURL stringByAppendingString:orderID];
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"PUT";
  [request setValue:token forHTTPHeaderField:@"eat"];
  
  NSError *error;
  NSDictionary *dictionary = @{@"OrderID":orderID};
  NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
  //NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  request.HTTPBody = data;
  
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    //NSLog(@"%@",response);
    
    //NSError *responseError;
    
    if (error) {
      completionHandler(nil, @"could not complete task");
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger statusCode = httpResponse.statusCode;
      NSLog(@"statusCode %ld", (long)statusCode);
      
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      
      
    });
  }];
  [dataTask resume];
}

//MARK: MakeDrinkOrder
-(void)putDrinkOrderToInProgress:(NSString *)drinkOrderID completionHandler:(void (^)(NSString *results, NSString *error))completionHandler {
  
  [self getMyToken];
  NSString *token = self.token;
  NSString *orderID = drinkOrderID;
  NSString *baseURL = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/drinkorder/";
  NSString *urlString = [baseURL stringByAppendingString:orderID];
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"PUT";
  
  [request setValue:token forHTTPHeaderField:@"eat"];
  
  NSError *error;
  NSDictionary *dictionary = @{@"OrderID":orderID};
  NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
  
  request.HTTPBody = data;
  
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    
    if (error) {
      completionHandler(nil, @"could not complete task");
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger statusCode = httpResponse.statusCode;
      NSLog(@"statusCode %ld", (long)statusCode);
      
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      
      
    });
  }];
  [dataTask resume];
}



@end
