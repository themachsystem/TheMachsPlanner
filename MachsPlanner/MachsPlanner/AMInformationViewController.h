//
//  AMInformationViewController.h
//  MachsPlanner
//
//  Created by Alvis Mach on 31/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBPopupMenu.h"

@interface AMInformationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *informationTextView;
@property (strong, nonatomic) NSString *placeInfoString;
@property (strong, nonatomic) NSString *titleHeader;
@property (strong, nonatomic) NSArray *listOfPlaces;
@property (strong, nonatomic) IBOutlet UISegmentedControl *headerTabSection;
@property (strong, nonatomic) UITableView *photoTableView;
@property (strong, nonatomic) NSArray *placeOfInterestArray;
@property (nonatomic, strong) QBPopupMenu *popupMenu;


- (IBAction)headerTabChanged:(UISegmentedControl *)sender;
@end
