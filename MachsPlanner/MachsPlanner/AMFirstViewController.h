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
@property (strong, nonatomic) IBOutlet UIWebView *informationWebView;
@property (strong, nonatomic) IBOutlet UITableView *menuTableView;
@property (strong, nonatomic) NSArray *categoryArray;
@property (strong, nonatomic) NSArray *placeLocationArray;
@property (strong, nonatomic) NSMutableArray *menuArray;
@property (strong, nonatomic) NSMutableArray *placeInfoArray;
@end
