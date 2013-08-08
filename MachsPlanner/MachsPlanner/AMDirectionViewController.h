//
//  AMDirectionViewController.h
//  MachsPlanner
//
//  Created by Alvis Mach on 9/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"
@interface AMDirectionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    BOOL isShownRouteTable;
    IBOutlet UILabel *headerTitle;
    IBOutlet UILabel *smallHeaderTitle;
    int count;
    int numberOfSections;
    int numberOfCurrSubSteps;
    NSMutableDictionary *expandedSectionDict;
    UIButton *currButton;
}

@property (strong, nonatomic) MapView *directionView;
@property (nonatomic,strong)  UITableView *routeTableView;

// Route info =======
@property (nonatomic,strong) NSArray *routeArray;
@property (nonatomic,strong) NSString *distance;
@property (nonatomic,strong) NSString *duration;
@property (nonatomic,strong) NSString *destionationTitle;
@property (nonatomic,strong) NSMutableArray *routeInstructionArray;

- (void)passDistance:(NSString*)distance duration:(NSString*)duration routeArray:(NSArray*)array;

- (IBAction)closeDirectionView:(id)sender;
- (IBAction)showRouteTable:(id)sender;

@end
