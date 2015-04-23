//
//  BarsTableViewController.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/25/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "BarsTableViewController.h"
#import "NetworkController.h"

@interface BarsTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSArray *availableBars;
@property (strong, nonatomic) IBOutlet UITableView *barsTableView;


@end

@implementation BarsTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.barsTableView.rowHeight = 85;
  self.barsTableView.dataSource = self;
  self.barsTableView.delegate = self;
  UINib *cellNib =[UINib nibWithNibName:@"BarCell" bundle:[NSBundle mainBundle]];
  [self.barsTableView registerNib:cellNib forCellReuseIdentifier:@"BAR_CELL"];
  
  
  [[NetworkController sharedService] fetchAvailableBars:@"Seattle" completionHandler:^(NSArray *results, NSString *error) {
    self.availableBars = [[NSArray alloc] initWithArray:results];
    [self.barsTableView reloadData];
  }];
  
}

-(void)viewDidAppear:(BOOL)animated {
  //If user default token is blank
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *token = [userDefaults objectForKey:@"token"];
  if (token == nil) {
    [self gotoCustomerSignup];
  }

  
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return self.availableBars.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  BarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAR_CELL" forIndexPath:indexPath];

  Bar *bar = self.availableBars[indexPath.row];
  cell.barName.text = bar.barName;
  cell.barLocation.text = bar.barID;
  return cell;
  
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"ORDER_DRINKS" sender:self];
}


//MARK: SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ORDER_DRINKS"]) {
    OrderingViewController *destinationVC = (OrderingViewController *)segue.destinationViewController;
    NSIndexPath *indexPath = self.barsTableView.indexPathForSelectedRow;
    //NSDictionary *bar = self.availableBars[indexPath.row];
    destinationVC.barName = @"Unicorn"; //replace with bar[@"Name"];
  }
}


//Go to User Profile
-(void)gotoCustomerSignup {
  //UINavigationController *vcUserProfiles = [self.storyboard instantiateViewControllerWithIdentifier:(@"CustomerSignup")];
  SignUpVC *vcUserProfile = [self.storyboard instantiateViewControllerWithIdentifier:(@"CustomerSignup")];

  [self presentViewController:(vcUserProfile) animated:true completion:nil];
}



@end
