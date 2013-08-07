//
//  AMInformationViewController.m
//  MachsPlanner
//
//  Created by Alvis Mach on 31/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import "AMInformationViewController.h"

@interface AMInformationViewController ()

@end

@implementation AMInformationViewController
@synthesize informationTextView = _informationTextView;
@synthesize placeInfoString = _placeInfoString;
@synthesize listOfPlaces = _listOfPlaces;
@synthesize titleHeader = _titleHeader;
@synthesize headerTabSection = _headerTabSection;
@synthesize photoTableView = _photoTableView;
@synthesize placeOfInterestArray = _placeOfInterestArray;
@synthesize popupMenu = _popupMenu;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _informationTextView.text = self.placeInfoString;
    self.title = _titleHeader;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)createTableView{
    if (_photoTableView) {
        [_photoTableView removeFromSuperview];
        _photoTableView = nil;
    }
    [_photoTableView reloadData];
    if ([_placeOfInterestArray count]<=10) { //
        _photoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,40, 320, 44*[_placeOfInterestArray count])];
    }
    else {
        _photoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,40, 320, 460)];
    }
    _photoTableView.dataSource = self;
    _photoTableView.delegate = self;
    _photoTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _photoTableView.backgroundColor = [UIColor grayColor];
    [_photoTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}
#pragma mark - Table View Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_placeOfInterestArray count];
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
    
    
    cell.textLabel.font = [UIFont fontWithName:@"Thonburi" size:14];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[_placeOfInterestArray objectAtIndex:indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] init];
    QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:@"Place information" target:self action:@selector(placeAcitivity:)];
    item1.width = 130;
    
    QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:@"Find place" target:self action:@selector(placeAcitivity:)];
    item2.width = 80;
    
    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:@"See photos" target:self action:@selector(placeAcitivity:)];
    item3.width = 90;
    
    popupMenu.items = [NSArray arrayWithObjects:item1, item2, item3, nil];
    self.popupMenu = popupMenu;
    [self.popupMenu showInView:self.view atPoint:CGPointMake([tableView cellForRowAtIndexPath:indexPath].center.x, [tableView cellForRowAtIndexPath:indexPath].frame.origin.y+64)];
}

- (void)placeAcitivity:(QBPopupMenuItem*)sender{
    
}
- (IBAction)headerTabChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 1:
            if (!_informationTextView.isHidden) {
                [_informationTextView setHidden:YES];

            }
            [self createTableView];
            [self.view addSubview:_photoTableView];
            break;
            
        default:
            if (_informationTextView.isHidden) {
                [_informationTextView setHidden:NO];
            }
            if (_photoTableView) {
                [_photoTableView removeFromSuperview];
                _photoTableView = nil;
            }
            break;
    }
}
@end
