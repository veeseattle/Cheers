//
//  CustomerSignupViewController.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/25/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "SignUpVC.h"
#import "ImagePickerObject.h"

@interface SignUpVC() <UITextFieldDelegate, ImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *userPicture;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *password2Field;
@property (strong,nonatomic) NSString *imageString;
@property (weak, nonatomic) IBOutlet UITextField *promoCode;
@property (weak, nonatomic) IBOutlet UIView *square;
@property (strong,nonatomic) ImagePickerObject *imagePicker;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) UIView *viewWindow;
@property (nonatomic, strong) UIViewController *viewController;
@property (strong,nonatomic) Customer *customer;


- (IBAction)signUpButtonClicked:(id)sender;


@end

@implementation SignUpVC

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.customer = [[Customer alloc] init];
  
  self.square.layer.cornerRadius = 20;
  
  self.nameField.delegate = self;
  self.nameField.text =  self.customer.name;
  self.emailField.delegate = self;
  self.emailField.text = self.customer.emailAddress;
  self.passwordField.delegate = self;
  self.passwordField.text = self.customer.password;
  self.password2Field.delegate = self;
  self.promoCode.delegate = self;
  self.promoCode.text = self.customer.promoCode;
  
  
  
  //User picture set-up
  self.userPicture.layer.cornerRadius = 50;
  self.userPicture.layer.masksToBounds = true;
  self.userPicture.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.userPicture.layer.borderWidth = 3;
  self.userPicture.contentMode = UIViewContentModeScaleToFill;
  [self.userPicture addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  
  
  //Camera button
  UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)];
  self.navigationItem.rightBarButtonItem = cameraButton;
  
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField {
//  textField.resignFirstResponder;
//  return true;
//}

//Camera Button Pressed
-(void)cameraButtonPressed {
  ImagePickerObject *imagePicker = [[ImagePickerObject alloc] init];
  self.imagePicker = imagePicker;
  imagePicker.delegate = self;
  if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
    UIView *view = self.viewWindow;
    [imagePicker presentFromRect:[view convertRect:self.view.bounds fromView:self.view] inView:self.viewWindow];
  } else {
    [imagePicker presentWithViewController:self];
  }
}

//MARK: AdjustImage - make image smaller
-(UIImage *) adjustImage:(UIImage *)image toSmallerSize:(CGSize)newSize {
  
  UIGraphicsBeginImageContext(newSize);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

//Turn image to NSString
-(void)turnImageIntoJSON {
  UIImage *userImage = [self adjustImage:self.customer.image toSmallerSize:CGSizeMake(100,100)];
  NSData *imageData = UIImageJPEGRepresentation(userImage, 0.8);
  NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  
  self.imageString = imageString;
}


#pragma mark - signUpButtonClicked
- (IBAction)signUpButtonClicked:(id)sender {
  
  //make sure email is not blank
  if ([self.emailField.text isEqualToString:@""]) {
    UIAlertView *blankEmailAlert = [[UIAlertView alloc] initWithTitle:@"Email Not Entered" message:@"Please enter a valid email address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [blankEmailAlert show];
  }
  
  //make sure both password fields contain equal value
  if (![self.password2Field.text isEqualToString:self.passwordField.text]) {
    UIAlertView *passwordErrorAlert = [[UIAlertView alloc] initWithTitle:@"Password Error" message:@"Please check your password to make sure both fields match" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [passwordErrorAlert show];
  }
  
  //check for no picture
  if (!self.customer.image) {
    UIAlertView *blankPictureAlert = [[UIAlertView alloc] initWithTitle:@"No Picture Found" message:@"Please upload an image to complete registration" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [blankPictureAlert show];
  }
  
  else {
    [self turnImageIntoJSON];

    NSDictionary *customer = @{@"username" : self.nameField.text, @"email" : self.emailField.text, @"password" : self.passwordField.text, @"userPic" : self.imageString, @"promoCode" : self.promoCode.text};
   
    [[NetworkController sharedService] createNewUser:customer completionHandler:^(NSString *results, NSString *error) {
      [self dismissViewControllerAnimated:true completion:nil];
    }];
    
  }
}

#pragma mark - ImagePickerObjectDelegate
- (void)imagePicker:(ImagePickerObject *)imagePicker didSelectImage:(UIImage *)image
{
  
  UIImage *chosenImage = image;
  self.customer.image = chosenImage;
  [self.userPicture setBackgroundImage:chosenImage forState:UIControlStateNormal];
  
  //Save selected image locally
  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

  NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"MyPicture.jpg"];
  
  NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.85);
  [imageData writeToFile:filePath atomically:YES];
  
  self.imagePicker = nil;
}


- (void)imagePickerDidCancel:(ImagePickerObject *)imagePicker
{
  self.imagePicker = nil;
}


@end
