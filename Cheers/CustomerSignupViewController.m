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
@property (weak, nonatomic) IBOutlet UIView *formFrame;
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
  
  //Set up form frame
  self.formFrame.layer.borderColor = [[UIColor grayColor] CGColor];
  self.formFrame.layer.borderWidth = 1;
  
  //Set up text fields and get data to Customer object
  self.nameField.delegate = self;
  self.nameField.text =  customer.name;
  self.emailField.delegate = self;
  self.emailField.text = customer.emailAddress;
  self.passwordField.delegate = self;
  self.passwordField.text = customer.password;
  self.password2Field.delegate = self;
  
  
  //Get user picture
  if (customer.image != nil) {
    self.userPicture.image = customer.image;
  }
  else {
    self.userPicture.image = [UIImage imageNamed:@"juju.jpg"];
  }
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
  [picker dismissViewControllerAnimated:YES completion:NULL];
  
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [picker dismissViewControllerAnimated:YES completion:NULL];
  
}


- (IBAction)signUpButton:(id)sender {
  
  if ([self.emailField.text isEqualToString:@""]) {
    UIAlertView *blankEmailAlert = [[UIAlertView alloc] initWithTitle:@"Email not entered" message:@"Please enter an email address" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [blankEmailAlert show];
  }
  else {
    [self performSegueWithIdentifier:@"SELECT_BAR" sender:self];
  }
}

@end
