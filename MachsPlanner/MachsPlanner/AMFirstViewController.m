//
//  AMViewController.m
//  test
//
//  Created by Alvis Mach on 19/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import "AMFirstViewController.h"
#import "AMInformationViewController.h"
#import "AMCoreDataManager.h"
@interface AMFirstViewController (){
    NSManagedObjectContext *context;
}

@end

@implementation AMFirstViewController
@synthesize menuTableView = _menuTableView;
@synthesize menuArray = _menuArray;
@synthesize placeInfoArray = _placeInfoArray;
@synthesize categoryArray = _categoryArray;
@synthesize placeLocationArray = _placeLocationArray;
- (void)viewDidLoad
{
    [super viewDidLoad];
    _categoryArray = [[AMCoreDataManager shareManager]fetchAllCategories];
    _placeLocationArray = [[AMCoreDataManager shareManager]fetchPlaceLocationAndDescription];
    self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:nil
                                                                           action:nil];
    [_menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    _menuArray = [[NSMutableArray alloc] init];
    _placeInfoArray = [[NSMutableArray alloc] init];
    for (TBLCategories *category in _categoryArray) {
        [_menuArray addObject:category.colCategoryName];
        [_placeInfoArray addObject:category.colCategoryDescription];
    }
    ;

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_menuArray count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell ==nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[_menuArray objectAtIndex:indexPath.row]];
    cell.textLabel.font = [UIFont fontWithName:@"Thonburi" size:14];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AMInformationViewController *infoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AMInformationViewController"];
    
    infoViewController.placeInfoString = [NSString stringWithFormat:@"%@",[_placeInfoArray objectAtIndex:indexPath.row]];
    infoViewController.titleHeader = [NSString stringWithFormat:@"%@",[_menuArray objectAtIndex:indexPath.row]];
    infoViewController.placeOfInterestArray = [self filterPlaceOfInterestWithIndex:indexPath.row];
    infoViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:infoViewController animated:YES];

}

- (NSArray*)filterPlaceOfInterestWithIndex:(int)index{
    NSMutableArray *placeOfInterest = [[NSMutableArray alloc] init];
    for (TBLPlaceLocation *placeLocation in _placeLocationArray) {
        if (placeLocation.colIdCategories==index+1) {
            [placeOfInterest addObject:placeLocation];
        }
    }
    return placeOfInterest;
}

@end
