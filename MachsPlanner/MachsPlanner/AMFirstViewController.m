//
//  AMViewController.m
//  test
//
//  Created by Alvis Mach on 19/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import "AMFirstViewController.h"
#import "AMInformationViewController.h"
@interface AMFirstViewController ()

@end

@implementation AMFirstViewController
@synthesize menuTableView = _menuTableView;
@synthesize menuArray = _menuArray;
@synthesize placeInfoArray = _placeInfoArray;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:nil
                                                                           action:nil];
    [_menuTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    _menuArray = [[NSArray alloc] initWithObjects:@"Sydney's Parks & Gardens",@"Places of Worship in Sydney",@"Shopping in Sydney",@"Museums & Galleries",@"Sydney Opera House",@"Sydney Harbour Bridge", nil];
    NSString * tempDictPath = [[NSBundle mainBundle] pathForResource:@"PlaceInfoDetail" ofType:@"plist"];
    _placeInfoArray = [NSArray arrayWithContentsOfFile:tempDictPath];
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
    NSArray *placeOfInterest;
    switch (index) {
        case 0:
            placeOfInterest= [NSArray arrayWithObjects:@"Royal Botanic Gardens",@"Hyde Park",@"Centennial Park",@"Cook & Phillip Park",@"The Domain",@"The Chinese Garden of Friendship", nil];
            break;
        case 1:
            placeOfInterest= [NSArray arrayWithObjects:@"The Great Synagogue",@"St Marys Cathedral",@"St James",@"St Andrew's Cathedral",@"St Philip's",nil];
            break;
        case 2:
            placeOfInterest= [NSArray arrayWithObjects:@"The Queen Victoria Building",@"The Strand Arcade",@"Skygarden", nil];
            break;
        case 3:
            placeOfInterest= [NSArray arrayWithObjects:@"Art Gallery of NSW",@"Australian Museum",@"Justice and Police Museum",@"Museum of Contemporary Art",@"Museum of Sydney",@"Australian National Maritime Museum",@"Hyde Park Barracks Museum",@"Powerhouse Museum",@"SH Ervin Gallery",@"Sydney Jewish Museum", nil];
            break;
        default:
            break;
    }
    return placeOfInterest;
}

@end
