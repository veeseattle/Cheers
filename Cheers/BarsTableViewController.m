//
//  BarsTableViewController.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/25/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "BarsTableViewController.h"

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
  
  self.availableBars = [[NSArray alloc] initWithObjects: @{@"Location" : @"Capitol Hill", @"Name" : @"Unicorn"}, @{@"Location" : @"Ballard", @"Name" : @"Bel Mar"}, nil];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewDidAppear:(BOOL)animated {
  //If user default token is blank
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *token = [userDefaults objectForKey:@"token"];
  if (token == nil) {
    [self gotoCustomerSignup];
  }

  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:@"ORDER_DRINKS" sender:self];
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

  NSDictionary *bar = self.availableBars[indexPath.row];
  cell.barName.text = bar[@"Name"];
  cell.barLocation.text = bar[@"Location"];
//  cell.barName.text = @"Unicorn";
//  cell.barLocation.text = @"Capitol Hill";
  return cell;
}


//MARK: SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ORDER_DRINKS"]) {
    OrderingViewController *destinationVC = (OrderingViewController *)segue.destinationViewController;
    NSIndexPath *indexPath = self.barsTableView.indexPathForSelectedRow;
    NSDictionary *bar = self.availableBars[indexPath.row];
   // destinationVC.barName = bar[@"Name"];
  }
}


//Go to User Profile
-(void)gotoCustomerSignup {
  //UINavigationController *vcUserProfiles = [self.storyboard instantiateViewControllerWithIdentifier:(@"CustomerSignup")];
  CustomerSignupViewController *vcUserProfile = [self.storyboard instantiateViewControllerWithIdentifier:(@"CustomerSignup")];

  [self presentViewController:(vcUserProfile) animated:true completion:nil];
}



@end
