//
//  CustomerSignupViewController.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/25/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "CustomerSignupViewController.h"

@interface CustomerSignupViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userPicture;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *password2Field;
@property (strong,nonatomic) NSString *imageString;
@property (weak, nonatomic) IBOutlet UITextField *promoCode;

- (IBAction)signUpButton:(id)sender;


@end

@implementation CustomerSignupViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //check for camera
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Device has no camera"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    [myAlertView show];
  }
  
  Customer *customer = [[Customer alloc] init];
  
  //Set up text fields and get data to Customer object
  self.nameField.delegate = self;
  self.nameField.text =  customer.name;
  self.emailField.delegate = self;
  self.emailField.text = customer.emailAddress;
  self.passwordField.delegate = self;
  self.passwordField.text = customer.password;
  self.password2Field.delegate = self;
  self.promoCode.delegate = self;
  self.promoCode.text = customer.promoCode;
  
  //Get user picture
  if (customer.image != nil) {
    self.userPicture.image = customer.image;
  }
  else {
    self.userPicture.image = [UIImage imageNamed:@"juju.jpg"];
  }
  //User picture set-up
  self.userPicture.layer.cornerRadius = 50;
  self.userPicture.layer.masksToBounds = true;
  self.userPicture.layer.borderColor = [[UIColor whiteColor] CGColor];
  self.userPicture.layer.borderWidth = 6;
  self.userPicture.contentMode = UIViewContentModeScaleAspectFit;
  
  //Camera button
  UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonPressed)];
  self.navigationItem.rightBarButtonItem = cameraButton;
  
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  textField.resignFirstResponder;
  return true;
}

//Camera Button Pressed
-(void)cameraButtonPressed {
  UIImagePickerController *picturePicker = [[UIImagePickerController alloc] init];
  picturePicker.delegate = self;
  picturePicker.allowsEditing = true;
  picturePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  
  [self.navigationController presentViewController:picturePicker animated:true completion:nil];
  
  
}


//MARK: Image Picker Controller Delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  
  UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
  self.userPicture.image = chosenImage;
  
  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSString *imageSubdirectory = [documentsDirectory stringByAppendingPathComponent:@"MySubfolderName"];
  
  NSString *filePath = [imageSubdirectory stringByAppendingPathComponent:@"MyImage.jpg"];
  
  NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.85);
  [imageData writeToFile:filePath atomically:YES];
  
  
  [picker dismissViewControllerAnimated:YES completion:NULL];
  
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:NULL];
  
}

//MARK: AdjustImage - make image smaller
-(UIImage *) adjustImage:(UIImage *)image toSmallerSize:(CGSize)newSize {
  
  NSLog(@"Image made smaller");
  
  UIGraphicsBeginImageContext(newSize);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return newImage;
}

//Turn image to NSString
-(void)turnImageIntoJSON {
  UIImage *userImage = [self adjustImage:self.userPicture.image toSmallerSize:CGSizeMake(100,100)];
  NSData *imageData = UIImageJPEGRepresentation(userImage, 0.8);
  NSString *imageString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
  
  self.imageString = imageString;
}


//MARK: Submit button pressed
- (IBAction)signUpButton:(id)sender {
  
  //make sure email is not blank
  if ([self.emailField.text isEqualToString:@""]) {
    UIAlertView *blankEmailAlert = [[UIAlertView alloc] initWithTitle:@"Email not entered" message:@"Please enter an email address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [blankEmailAlert show];
  }
  else {
    [self turnImageIntoJSON];

    NSDictionary *customer = @{@"username" : self.nameField.text, @"email" : self.emailField.text, @"password" : self.passwordField.text, @"userPic" : self.imageString, @"promoCode" : self.promoCode.text};
   
    [[NetworkController sharedService] postCustomerID:customer completionHandler:^(NSString *results, NSString *error) {
      [self dismissViewControllerAnimated:true completion:nil];
    }];
    
  }
}

@end
