//
//  AMInformationViewController.m
//  MachsPlanner
//
//  Created by Alvis Mach on 31/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import "AMInformationViewController.h"
#import "AMCoreDataManager.h"
#import "AMSecondViewController.h"
@interface AMInformationViewController ()

@end

@implementation AMInformationViewController
@synthesize informationWebview = _informationWebview;
@synthesize placeInfoString = _placeInfoString;
@synthesize listOfPlaces = _listOfPlaces;
@synthesize titleHeader = _titleHeader;
@synthesize headerTabSection = _headerTabSection;
@synthesize photoTableView = _photoTableView;
@synthesize placeOfInterestArray = _placeOfInterestArray;
@synthesize popupMenu = _popupMenu;
@synthesize placeInfoWebview = _placeInfoWebview;
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
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn addTarget:self action:@selector(backtoInfoView:) forControlEvents:UIControlEventTouchDown];
    UIImage *backBtnImage = [UIImage imageNamed:@"BackButton.png"] ;
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(_informationWebview.frame.origin.x, _informationWebview.frame.origin.y, backBtnImage.size.width, backBtnImage.size.height);

    _placeInfoWebview = [[UIWebView alloc] initWithFrame:CGRectMake(_informationWebview.frame.origin.x, _informationWebview.frame.origin.y+backBtnImage.size.height, _informationWebview.frame.size.width, _informationWebview.frame.size.height-backBtnImage.size.height)];
    
    [self.view addSubview:_placeInfoWebview];
    [self.view addSubview:backBtn];

    [backBtn setHidden:YES];
    [_placeInfoWebview setHidden:YES];
    [_informationWebview loadHTMLString:self.placeInfoString baseURL:nil];
    self.title = _titleHeader;
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
    TBLPlaceLocation *placeLocation = [_placeOfInterestArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",placeLocation.colPlaceName];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    indexOfRowSelected = indexPath.row;
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
    TBLPlaceLocation *placeLocation = [_placeOfInterestArray objectAtIndex:indexOfRowSelected];
    if ([sender.title isEqualToString:@"Place information"]) {
        [_photoTableView setHidden:YES];
        [backBtn setHidden:NO];
        [_placeInfoWebview setHidden:NO];
        [_placeInfoWebview loadHTMLString:[NSString stringWithFormat:@"%@",placeLocation.colPlaceInfo] baseURL:nil];
        _placeInfoWebview.delegate = self;
    }
    else if ([sender.title isEqualToString:@"Find place"]){
        AMSecondViewController *mapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AMSecondViewController"];
        mapViewController.destLongitude = placeLocation.colLongitude;
        mapViewController.destLatitude = placeLocation.colLatitude;
        mapViewController.destionationTitle = placeLocation.colPlaceName;
        [mapViewController performSelector:@selector(searchCoordinatesForAddress:) withObject:placeLocation.colAddress afterDelay:1];
        for (UIView *subviews in mapViewController.view.subviews) {
            subviews.frame = CGRectMake(subviews.frame.origin.x, subviews.frame.origin.y-20, subviews.frame.size.width, subviews.frame.size.height);
        }
        self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Back"
                    
                                                                                style:UIBarButtonItemStyleBordered
                                                                               target:nil
                                                                               action:nil];
        mapViewController.title = @"Find place";
        [self.navigationController pushViewController:mapViewController animated:YES];
        
    }
    else {
        
    }
}
#pragma mark - WebView Delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    /** Makes a fit content size*/
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    if (fittingSize.height>_informationWebview.frame.size.height-backBtn.frame.size.height)
        fittingSize.height = _informationWebview.frame.size.height-backBtn.frame.size.height;
    webView.frame = CGRectMake(webView.frame.origin.x, webView.frame.origin.y, 320, fittingSize.height);
}

#pragma mark -

- (void)backtoInfoView:(UIButton*)sender{
    [_placeInfoWebview setHidden:YES];
    [backBtn setHidden:YES];
    [_photoTableView setHidden:NO];
}
- (IBAction)headerTabChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 1:
            if (!_informationWebview.isHidden) {
                [_informationWebview setHidden:YES];

            }
            
            [self createTableView];
            [self.view addSubview:_photoTableView];
            break;
            
        default:
            if (_informationWebview.isHidden) {
                [_informationWebview setHidden:NO];
            }
            if (!backBtn.isHidden) {
                [backBtn setHidden:YES];
            }
            if (!_placeInfoWebview.isHidden) {
                [_placeInfoWebview setHidden:YES];
            }
            if (_photoTableView) {
                [_photoTableView removeFromSuperview];
                _photoTableView = nil;
            }
            break;
    }
}
@end
