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
  
  self.availableBars = [[NSArray alloc] initWithObjects: @[ @{@"Location" : @"Capitol Hill", @"Name" : @"Unicorn"}, @{@"Location" : @"Ballard", @"Name" : @"Bel Mar"}], nil];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
  return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  BarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BAR_CELL" forIndexPath:indexPath];
  //NSDictionary *bar = self.availableBars[indexPath.row];
//  cell.barName.text = bar.barName;
//  cell.barLocation.text = bar.location;
  cell.barName.text = @"Unicorn";
  cell.barLocation.text = @"Capitol Hill";
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




/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */




@end
