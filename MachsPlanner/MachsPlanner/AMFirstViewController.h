//
//  AMFirstViewController.h
//  MachsPlanner
//
//  Created by Alvis Mach on 5/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface AMFirstViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    
}

@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSArray *menuArray;
@property (strong, nonatomic) NSArray *placeInfoArray;
@end
