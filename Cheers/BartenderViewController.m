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

@interface BartenderViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *barPicture;
@property (weak, nonatomic) IBOutlet UITableView *orderTable;
@property (weak, nonatomic) NSMutableArray *pendingOrders;


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
  
  // Do any additional setup after loading the view.
}

//MARK: Order Table Setup
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [[NetworkController sharedService] fetchOrdersForBar:@"Stout - Capitol Hill" completionHandler:^(NSArray *results, NSString *error) {
    //append only NEW results to pendingOrders - or reload?
  }];
  
  DrinkOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ORDER_CELL" forIndexPath:indexPath];
  cell.drinkName.text = @"Cosmo";
  cell.customerName.text = @"Brad";
  cell.customerPicture.image = [UIImage imageNamed:@"brad.jpeg"];
  cell.customerPicture.layer.cornerRadius = 30;
  cell.customerPicture.contentMode = UIViewContentModeScaleAspectFill;
  cell.customerPicture.layer.masksToBounds = true;
  
  return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 4; //replace this with number of order for this hotel
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


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

  if (editingStyle == UITableViewCellEditingStyleDelete) {
    Order *deletedOrder = self.pendingOrders[indexPath.row];
    deletedOrder.status = @"Completed";
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
