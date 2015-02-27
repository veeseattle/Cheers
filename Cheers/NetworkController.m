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
@property (strong,nonatomic) NSString *token;
@end

@implementation NetworkController

- (void)viewDidLoad {
    [super viewDidLoad];


    // Do any additional setup after loading the view.
}

-(void)getMyToken {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *token = [userDefaults objectForKey:@"token"];
  self.token = token;
}


+(id)sharedService {
  
  static NetworkController *mySharedService;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    mySharedService = [[NetworkController alloc] init];
  });
  return mySharedService;
}

//MARK: CreateNewUser - WORKING! & save token to profile
-(void)postCustomerID:(NSDictionary *)User completionHandler:(void (^)(NSString *results, NSString *error))completionHandler {
  //Heroku URL
  NSString *authURL = @"https://cheers-bartender-app.herokuapp.com/api/v1/create_user";
  NSURL *url = [NSURL URLWithString:authURL];
  NSLog(@"%@", url);
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: url];
  //[postRequest setURL:[NSURL URLWithString:@"POST"]];
  
  NSDictionary *customer = User;
  
  NSString *post = [NSString stringWithFormat:@"%@",customer];
  
  NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
  
  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
  
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:customer options:0 error:&error];
  //NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

  request.HTTPBody = data;
  
  request.HTTPMethod = @"POST";
  
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    //NSLog(@"%@",response);
    
    NSError *responseError;
  
    NSDictionary *tokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&responseError];
    NSString *token = tokenResponse[@"eat"];
    
    //NSString *token = [NSString stringWithFormat:@"%@",tokenResponse];
    //NSLog(token);
   
//    NSArray *components = [[tokenResponse description] componentsSeparatedByString:@"= \""];
//    NSString *token = components.lastObject;
//    NSArray *otherComponents = [[token description] componentsSeparatedByString:@"\""];
//    NSString *finalToken = otherComponents.firstObject;
//      NSLog(@"this is a token %@?", finalToken);
//
    if (error) {
      completionHandler(nil, @"could not complete task");
    } else {
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger statusCode = httpResponse.statusCode;
      NSLog(@"statusCode %ld", (long)statusCode);
      
      //Save token to NSUserDefaults
      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
      [userDefaults setObject:token forKey:@"token"]; //replace tokenResponse with finalToken
      [userDefaults synchronize];
      completionHandler(nil,nil);
      
      
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      
    
    });
  }];
  [dataTask resume];
}

//MARK: FetchAvailableDrinks -- will return id, name, recipe, and picture
-(void)fetchDrinksForBar:(NSString *)searchTerm completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler {
  
  [self getMyToken];
  NSString *token = self.token;
  NSString *urlString = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/drink";
 
  //NSLog(self.token);
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"GET";
  
  [request setValue:token forHTTPHeaderField:@"eat"];
//  NSString *post = self.token;
//  NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
  
//  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//  request.HTTPBody = postData;
  
  NSURLSession *session = [NSURLSession sharedSession];
  
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    if (error) {
      completionHandler(nil,@"Could not connect");
    } else {
      NSLog(@"gets here");
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

//MARK: FetchDrinkOrders
-(void)fetchOrdersForBar:(NSString *)searchTerm completionHandler:(void (^)(NSArray *results, NSString *error))completionHandler {
  
  [self getMyToken];
  
  NSString *token = self.token;
  
  NSString *urlString = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/drinkorder";
  
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"GET";
  
  [request setValue:token forHTTPHeaderField:@"eat"];

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

  NSData *data = [NSJSONSerialization dataWithJSONObject:drinkOrder options:0 error:&error];
  //NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  request.HTTPBody = data;
  
//  NSString *post = [NSString stringWithFormat:@"%@",drinkOrder];
//  
//  NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//  
//  NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
//  
//  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//  

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
-(void)putDrinkCompletion:(NSString *)orderID completionHandler:(void (^)(NSString *results, NSString *error))completionHandler {
  
  
  [self getMyToken];
  NSString *token = self.token;
  NSString *queryString = orderID;
  NSString *urlString = @"https://cheers-bartender-app.herokuapp.com/api/v1/cheers/drinkorder/completed/";
  NSURL *url = [NSURL URLWithString:urlString];
  
  //NSLog(self.token);
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  request.HTTPMethod = @"PUT";
  
  [request setValue:token forHTTPHeaderField:@"eat"];
  
  NSError *error;
  NSData *data = [NSJSONSerialization dataWithJSONObject:orderID options:0 error:&error];
  //NSDictionary *body = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
  
  request.HTTPBody = data;
  
  NSURLSession *session = [NSURLSession sharedSession];
  NSURLSessionTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    //NSLog(@"%@",response);
    
    NSError *responseError;
    
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



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
