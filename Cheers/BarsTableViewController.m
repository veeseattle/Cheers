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
  
//  [[NetworkController sharedService] fetchAvailableBars:@"Seattle" completionHandler:^(NSArray *results, NSString *error) {
//    self.availableBars = [[NSArray alloc] initWithArray:results];
//    [self.barsTableView reloadData];
//  }];
  
  Bar *dummyBar = [[Bar alloc] init];
  dummyBar.barID = @"12345";
  dummyBar.barName = @"Dummy bar name";
  
  self.availableBars = [[NSArray alloc] init];
  self.availableBars = @[dummyBar];
  
  
  
}


#pragma mark - tableView dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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


#pragma mark - Segue on didSelectRow
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"ORDER_DRINKS"]) {
    OrderingViewController *destinationVC = (OrderingViewController *)segue.destinationViewController;
//    NSIndexPath *indexPath = self.barsTableView.indexPathForSelectedRow;
//    Bar *bar = self.availableBars[indexPath.row];
//    destinationVC.bar = bar;
  }
}


#pragma mark - goToCustomerSignUp
-(void)gotoCustomerSignup {
  SignUpVC *vcUserProfile = [self.storyboard instantiateViewControllerWithIdentifier:(@"CustomerSignup")];

  [self presentViewController:(vcUserProfile) animated:true completion:nil];
}



@end
