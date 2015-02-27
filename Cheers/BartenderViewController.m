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

@interface BartenderViewController () <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *barPicture;
@property (weak, nonatomic) IBOutlet UITableView *orderTable;
@property (strong, nonatomic) NSMutableArray *pendingOrders;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation BartenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  self.barPicture.image = [UIImage imageNamed:@"drink.jpg"];
  
  self.orderTable.rowHeight = 99;
  self.orderTable.dataSource = self;
  self.orderTable.delegate = self;
  UINib *cellNib =[UINib nibWithNibName:@"DrinkOrderCell" bundle:[NSBundle mainBundle]];
  [self.orderTable registerNib:cellNib forCellReuseIdentifier:@"ORDER_CELL"];
  
  [[NetworkController sharedService] fetchOrdersForBar:@"Unicorn - Capitol Hill" completionHandler:^(NSArray *results, NSString *error) {
    self.pendingOrders = results;
    [self.orderTable reloadData];
  }];
  
  // Do any additional setup after loading the view.
}

//MARK: Order Table Setup
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  DrinkOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ORDER_CELL" forIndexPath:indexPath];
  Order *order = self.pendingOrders[indexPath.row];

  cell.drinkName.text = order.orderID;
  cell.customerName.text = order.customerID;
  cell.customerPicture.image = [UIImage imageNamed:@"brad.jpeg"];
  cell.customerPicture.layer.cornerRadius = 30;
  cell.customerPicture.contentMode = UIViewContentModeScaleAspectFill;
  cell.customerPicture.layer.masksToBounds = true;
  
  return cell;
}


-(NSInteger)tableView:(UITableView *)orderTable numberOfRowsInSection:(NSInteger)section {
  return self.pendingOrders.count; //replace this with number of order for this hotel
}

////Function: Handle event when cell is selected.
//func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//  //Edit cell.
//  let cell = tableView.cellForRowAtIndexPath(indexPath) as AllergenCell
//  cell.selected = false
//  cell.switchIsAllergen.setOn(!cell.switchIsAllergen.on, animated: true)
//  //Update user profile.
//  selectedUserProfile.allergens[indexPath.row].sensitive = cell.switchIsAllergen.on
//} //end func

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  DrinkOrderCell *cell = tableView cellForRowAtIndexPath:indexPath;
//  cell.selected = false;
//  [cell.makeDrink setOn:true animated:true];
//  self.pendingOrders.
//  
//}

////Function: Set table cell edit functionality.
//func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//  if editingStyle == UITableViewCellEditingStyle.Delete {
//    //Update & Save data.
//    userProfiles.removeAtIndex(indexPath.row)
//    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//    appDelegate.saveUserProfilesToArchive(userProfiles)
//    //Reload table.
//    tableUserProfiles.reloadData()
//  } //end if
//} //end func


-(void)tableView:(UITableView *)orderTable commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Order *deletedOrder = self.pendingOrders[indexPath.row];
    NSString *deletedID = deletedOrder.orderID;
    NSString *deletedPicture = deletedOrder.customerPicture;
    NSLog(deletedPicture);
    NSDictionary *delete = @{@"orderID" : deletedID, @"deletedPicture" : deletedPicture};
    NSLog(deletedOrder.orderID);
    
    [[NetworkController sharedService] putDrinkCompletion:delete completionHandler:^(NSString *results, NSString *error) {
      NSLog(@"done!");
    }];
     
     [self.pendingOrders removeObjectAtIndex:(indexPath.row)];
     
    self.orderTable.reloadData;
  }
}
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

@end
