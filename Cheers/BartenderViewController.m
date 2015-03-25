//
//  BartenderViewController.m
//  Cheers
//
//  Created by Vania Kurniawati on 2/23/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import "BartenderViewController.h"
#import "OrderingViewController.h"
#import "DrinkOrderCell.h"
#import "NetworkController.h"
#import "MCSwipeTableViewCell.h"

@interface BartenderViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *barPicture;
@property (weak, nonatomic) IBOutlet UITableView *orderTable;
@property (strong, nonatomic) NSMutableArray *pendingOrders;
- (IBAction)refreshButton:(id)sender;

@end

@implementation BartenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.barPicture.image = [UIImage imageNamed:@"drink.jpg"];

  self.orderTable.rowHeight = 95;
  self.orderTable.dataSource = self;
  self.orderTable.delegate = self;
  UINib *cellNib =[UINib nibWithNibName:@"DrinkOrderCell" bundle:[NSBundle mainBundle]];
  [self.orderTable registerNib:cellNib forCellReuseIdentifier:@"ORDER_CELL"];
  
  [[NetworkController sharedService] fetchOrdersForBar:@"Unicorn - Capitol Hill" completionHandler:^(NSMutableArray *results, NSString *error) {
    self.pendingOrders = results;
    [self.orderTable reloadData];
  }];
  
  // Do any additional setup after loading the view.
}

//MARK: Order Table Setup
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  DrinkOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ORDER_CELL" forIndexPath:indexPath];
  Order *order = self.pendingOrders[indexPath.row];
  //NSLog(@"The order in progress status is %@",order.orderInProgress);

  cell.drinkName.text = order.drinkName;
  cell.customerName.text = order.customer;
  [[NetworkController sharedService] fetchDrinkPicture:order.customerPicture completionHandler:^(UIImage *image) {
    cell.customerPicture.image = image;
  }];
  
  cell.customerPicture.layer.cornerRadius = 30;
  cell.customerPicture.contentMode = UIViewContentModeScaleAspectFill;
  cell.customerPicture.layer.masksToBounds = true;
  
  BOOL beingMade = [order.orderInProgress boolValue];
  cell.beingMadeStatus.hidden = !(beingMade == YES);
  
    // Remove inset of iOS 7 separators.
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
      cell.separatorInset = UIEdgeInsetsZero;
    }
  
  
  UILabel *makeDrink = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
  makeDrink.text = NSLocalizedString(@"Make Drink", @"");
  makeDrink.textColor = [UIColor whiteColor];
  
  UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
  
  [cell setSwipeGestureWithView:makeDrink color:greenColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
    
    //submit network call to mark order as in progress
    
      }];
  
  UILabel *completeOrder = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 150, 44)];
  completeOrder.text = NSLocalizedString(@"Complete Order",@"");
  completeOrder.textColor = [UIColor whiteColor];
  
  UIColor *orangeColor = [UIColor colorWithRed:255.0 / 255.0 green:165.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
  
  [cell setSwipeGestureWithView:completeOrder color:orangeColor mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
    
    //submit network call to complete order
    [self.pendingOrders removeObjectAtIndex:(indexPath.row)];
    [[NetworkController sharedService] putDrinkCompletion:order.orderID completionHandler:^(NSString *results, NSString *error) {
      NSLog(@"unicorns");
    }];
    
    //[self.orderTable reloadData];
  }];
  
  return cell;
}



-(NSInteger)tableView:(UITableView *)orderTable numberOfRowsInSection:(NSInteger)section {
  return self.pendingOrders.count;
}

//-(void)tableView:(UITableView *)orderTable commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//  if (editingStyle == UITableViewCellEditingStyleDelete) {
//    Order *deletedOrder = self.pendingOrders[indexPath.row];
//    NSString *deletedID = deletedOrder.orderID;
//    
//    [[NetworkController sharedService] putDrinkCompletion:deletedID completionHandler:^(NSString *results, NSString *error) {
//      NSLog(@"done!");
//    }];
//     
//     [self.pendingOrders removeObjectAtIndex:(indexPath.row)];
//     
//    self.orderTable.reloadData;
//  }
//}

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

- (IBAction)refreshButton:(id)sender {
  //self.pendingOrders = nil;
  [[NetworkController sharedService] fetchOrdersForBar:@"Unicorn - Capitol Hill" completionHandler:^(NSMutableArray *results, NSString *error) {
    self.pendingOrders = results;
  [self.orderTable reloadData];
  }];
}

@end
