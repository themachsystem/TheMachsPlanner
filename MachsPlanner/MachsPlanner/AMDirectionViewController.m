//
//  AMDirectionViewController.m
//  MachsPlanner
//
//  Created by Alvis Mach on 9/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import "AMDirectionViewController.h"
#import "NSString+HTML.h"
#import "AMAppDelegate.h"
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 320.0f
#define CELL_CONTENT_MARGIN 15.0f
@interface AMDirectionViewController ()

@end

@implementation AMDirectionViewController
@synthesize directionView = _directionView;
@synthesize routeTableView = _routeTableView;
@synthesize distance = _distance;
@synthesize duration = _duration;
@synthesize destionationTitle = _destionationTitle;
@synthesize routeArray = _routeArray;
@synthesize routeInstructionArray = _routeInstructionArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)passDistance:(NSString *)distance duration:(NSString *)duration routeArray:(NSArray *)array{
        self.routeArray = array;
        self.distance = distance;
        self.duration = duration;
}

// Titles the header bar
- (void)nameTheTitle{
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if ([appDelegate.travelMode isEqualToString:@"r"]) {
        headerTitle.text = @"Public Transport";
    }
    else if ([appDelegate.travelMode isEqualToString:@"w"]){
        headerTitle.text = @"Walking";
    }
    else if ([appDelegate.travelMode isEqualToString:@"b"]){
        headerTitle.text = @"Biking";
    }
    else{
        headerTitle.text = @"Driving";
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    count=0;
    expandedSectionDict = [[NSMutableDictionary alloc] init];
    [self nameTheTitle];
    smallHeaderTitle.text = [NSString stringWithFormat:@"(%@ - %@)",self.distance,self.duration];
    smallHeaderTitle.font = [UIFont systemFontOfSize:12.0f];
    isShownRouteTable = NO;
    
    self.directionView = [[MapView alloc] initWithFrame:
                          CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height)] ;
    [self.view addSubview:self.directionView];
    [self showRouteMap];
}

// Gets an array of routing instructions
- (void)populateRouteInstructions{
    if (self.routeInstructionArray) {
        self.routeInstructionArray = nil;
        numberOfSections = 0;
    }
    self.routeInstructionArray = [[NSMutableArray alloc] init];
    NSDictionary *stepDict = [[self.routeArray objectAtIndex:0] objectForKey:@"steps"];
    int increment=0;
    for (NSDictionary*dict in stepDict) {
        NSMutableDictionary *routeInstructionDict = [[NSMutableDictionary alloc] init];
        NSString *instructions = [[NSString stringWithFormat:@"%@",[dict objectForKey:@"html_instructions"]]stringByConvertingHTMLToPlainText];
        NSString * distance = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"distance"] objectForKey:@"text"]];
        [routeInstructionDict setObject:instructions forKey:@"instructions"];
        [routeInstructionDict setObject:distance forKey:@"distance"];
        if ([dict objectForKey:@"steps"]) {
            numberOfSections++;
            NSMutableArray *subInstructionArray = [[NSMutableArray alloc] init];
            for (NSDictionary *subStepDict in [dict objectForKey:@"steps"]) {
                NSMutableDictionary *subRouteInstructDict = [[NSMutableDictionary alloc] init];
                NSString *subInstructions = [[NSString stringWithFormat:@"%@",[subStepDict objectForKey:@"html_instructions"]]stringByConvertingHTMLToPlainText];
                NSString * subDistance = [NSString stringWithFormat:@"%@",[[subStepDict objectForKey:@"distance"] objectForKey:@"text"]];
                if (([subInstructions rangeOfString:@"null"].location!= NSNotFound)||([subDistance rangeOfString:@"null"].location!= NSNotFound)) {
                    continue;
                }
                [subRouteInstructDict setObject:subInstructions forKey:@"instructions"];
                [subRouteInstructDict setObject:subDistance forKey:@"distance"];
                [subInstructionArray addObject:subRouteInstructDict];
            }
            if ([subInstructionArray count]>0) {
                [routeInstructionDict setObject:subInstructionArray forKey:@"subInstructions"];
            }
        }
        [self.routeInstructionArray addObject:routeInstructionDict];
        [expandedSectionDict setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:increment]];
        increment++;
    }
}

// Displays map view with routes
- (void)showRouteMap{
    NSString *fromDescription = [NSString stringWithFormat:@"%@",[[self.routeArray objectAtIndex:0] objectForKey:@"start_address"]];
    NSString *toDescription = [NSString stringWithFormat:@"%@",[[self.routeArray objectAtIndex:0] objectForKey:@"end_address"]];
    
    double fromLongitude = [[[[self.routeArray objectAtIndex:0] objectForKey:@"start_location"] objectForKey:@"lng" ]doubleValue];
    double fromLatitude = [[[[self.routeArray objectAtIndex:0] objectForKey:@"start_location"] objectForKey:@"lat" ]doubleValue];
    
    double toLongitude = [[[[self.routeArray objectAtIndex:0] objectForKey:@"end_location"] objectForKey:@"lng" ]doubleValue];
    double toLatitude = [[[[self.routeArray objectAtIndex:0] objectForKey:@"end_location"] objectForKey:@"lat" ]doubleValue];
    
    Place* currPlace = [[Place alloc] init];
    currPlace.name = @"Current location";
    currPlace.description = fromDescription;
    currPlace.latitude = fromLatitude;
    currPlace.longitude = fromLongitude;
    
    Place* destionation =[[Place alloc] init];
    destionation.name = (_destionationTitle)?:@"Destination";
    destionation.description = toDescription;
    destionation.latitude = toLatitude;
    destionation.longitude = toLongitude;
    [self.directionView passUserLocation:CLLocationCoordinate2DMake(fromLatitude, fromLongitude)];
    [self.directionView showRouteFrom:currPlace to:destionation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBAction
- (IBAction)closeDirectionView:(id)sender {
    if (isShownRouteTable) {
        [self.routeTableView removeFromSuperview];
        self.routeTableView = nil;
        isShownRouteTable = NO;
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)showRouteTable:(id)sender {
    if (!self.routeTableView) {
        [self createRouteTable];
        [self populateRouteInstructions];
        isShownRouteTable = YES;
        

    }

}
#pragma mark-
- (void)createRouteTable{
    self.routeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    [self.routeTableView reloadData];
    self.routeTableView.delegate = self;
    self.routeTableView.dataSource = self;

    [self.view addSubview:self.routeTableView];
}
#pragma mark -
#pragma mark Table View Delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.routeInstructionArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == currButton.tag) {
        return numberOfCurrSubSteps;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    NSString *text = [NSString stringWithFormat:@"%@",[[self.routeInstructionArray objectAtIndex:section]objectForKey:@"instructions"]];
    if ([text rangeOfString:@"Destination will be"].location!=NSNotFound) {
        NSString *destString = [text substringFromIndex:[text rangeOfString:@"Destination will be"].location];
        text = [text substringToIndex:[text rangeOfString:@"Destination will be"].location];
        text = [NSString stringWithFormat:@"%@\n%@",text, destString];
    }
    
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE+2] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height = size.height+CELL_CONTENT_MARGIN*2+22; 
    
    return height;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [NSString stringWithFormat:@"%@",[[[[self.routeInstructionArray objectAtIndex:indexPath.section]objectForKey:@"subInstructions"] objectAtIndex:indexPath.row] objectForKey:@"instructions"]];
    if ([text rangeOfString:@"Destination will be"].location!=NSNotFound) {
        NSString *destString = [text substringFromIndex:[text rangeOfString:@"Destination will be"].location];
        text = [text substringToIndex:[text rangeOfString:@"Destination will be"].location];
        text = [NSString stringWithFormat:@"%@\n%@",text, destString];
    }
    
    
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:FONT_SIZE] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat height = size.height+CELL_CONTENT_MARGIN*2+22; 

    return height;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell Route";
    UILabel *detailLabel = nil;
    UILabel *distanceLabel = nil;
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];   
                
        // Instruction text
        detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [detailLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [detailLabel setMinimumFontSize:FONT_SIZE];
        [detailLabel setNumberOfLines:0];
        [detailLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
        [detailLabel setTag:1];
        
        // Distance text
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, 200, 22)];
        [distanceLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE]];
        [distanceLabel setTag:0];
        [distanceLabel setText:[NSString stringWithFormat:@"%@",[[[[self.routeInstructionArray objectAtIndex:indexPath.section]objectForKey:@"subInstructions"] objectAtIndex:indexPath.row] objectForKey:@"distance"]]];
        [distanceLabel setTextColor:[UIColor grayColor]];
        
        [[cell contentView] addSubview:distanceLabel];
        [[cell contentView] addSubview:detailLabel];
    }
    NSString *text = [NSString stringWithFormat:@"%@",[[[[self.routeInstructionArray objectAtIndex:indexPath.section]objectForKey:@"subInstructions"] objectAtIndex:indexPath.row] objectForKey:@"instructions"]];
    if ([text rangeOfString:@"Destination will be"].location!=NSNotFound) {
        NSString *destString = [text substringFromIndex:[text rangeOfString:@"Destination will be"].location];
        text = [text substringToIndex:[text rangeOfString:@"Destination will be"].location];
        text = [NSString stringWithFormat:@"%@\n%@",text, destString];
    }
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGRect rect = [text boundingRectWithSize:constraint options:NSStringDrawingTruncatesLastVisibleLine attributes:nil context:nil];

    if (!detailLabel)
        detailLabel = (UILabel*)[cell viewWithTag:1];
    if (!distanceLabel) {
        distanceLabel = (UILabel*)[cell viewWithTag:0];
    }
    [detailLabel setText:text];
    [detailLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN+22, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), rect.size.height)];
    [detailLabel sizeToFit];
    cell.userInteractionEnabled = NO;
    
    cell.backgroundColor = [UIColor whiteColor];
//    [cell.contentView.layer setBorderColor:[UIColor redColor].CGColor];
//    [cell.contentView.layer setBorderWidth:4.0f];    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *CellIdentifier = @"Cell Route";
    UILabel *detailLabel = nil;
    UILabel *distanceLabel = nil;
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];   
        
        // Instruction text
        detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [detailLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [detailLabel setMinimumFontSize:FONT_SIZE+2];
        [detailLabel setNumberOfLines:0];
        [detailLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE+2]];
        [detailLabel setTag:1];
        
        // Distance text
        distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, 200, 22)];
        [distanceLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE+2]];
        [distanceLabel setTag:0];
        [distanceLabel setText:[NSString stringWithFormat:@"%@",[[self.routeInstructionArray objectAtIndex:section]objectForKey:@"distance"]]];
        [distanceLabel setTextColor:[UIColor grayColor]];
        
        [[cell contentView] addSubview:distanceLabel];
        [[cell contentView] addSubview:detailLabel];
    }
    NSString *text = [NSString stringWithFormat:@"%@",[[self.routeInstructionArray objectAtIndex:section]objectForKey:@"instructions"]];
    if ([text rangeOfString:@"Destination will be"].location!=NSNotFound) {
        NSString *destString = [text substringFromIndex:[text rangeOfString:@"Destination will be"].location];
        text = [text substringToIndex:[text rangeOfString:@"Destination will be"].location];
        text = [NSString stringWithFormat:@"%@\n%@",text, destString];
    }
    CGSize constraint = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), 20000.0f);
    
    CGRect rect = [text boundingRectWithSize:constraint options:NSStringDrawingTruncatesLastVisibleLine attributes:nil context:nil];
    
    if (!detailLabel)
        detailLabel = (UILabel*)[cell viewWithTag:1];
    if (!distanceLabel) {
        distanceLabel = (UILabel*)[cell viewWithTag:0];
    }
    [detailLabel setText:text];
    [detailLabel setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN+22, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), rect.size.height)];
    [detailLabel sizeToFit];
    cell.userInteractionEnabled = NO;
    if ([[self.routeInstructionArray objectAtIndex:section]objectForKey:@"subInstructions"]) {
        cell.userInteractionEnabled = YES;
        UIButton *showDetail=[UIButton buttonWithType:UIButtonTypeCustom];
        [showDetail setFrame:CGRectMake(0, 0, 320, detailLabel.frame.size.height+CELL_CONTENT_MARGIN*2+22)];
        [showDetail addTarget:self action:@selector(showDetailRoute:) forControlEvents:UIControlEventTouchUpInside];
        [showDetail setImage:[UIImage imageNamed:@"expand-steps.png"] forState:UIControlStateNormal];
        [showDetail setImage:[UIImage imageNamed:@"collapse-steps.png"] forState:UIControlStateSelected];
        showDetail.imageEdgeInsets= UIEdgeInsetsMake(showDetail.frame.size.height-40, 0, 0, -280);
        showDetail.tag = section;
        [[cell contentView] addSubview:showDetail];
        
    }
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [cell.contentView.layer setBorderColor:[UIColor brownColor].CGColor];
    [cell.contentView.layer setBorderWidth:4.0f];    

    return cell;
}
#pragma mark-
// Expands route's sub-steps
- (void)showDetailRoute:(UIButton*)sender{
    // Collapses the current table's section if been opened already ========================================
    if ([[expandedSectionDict objectForKey:[NSNumber numberWithInt:sender.tag]]boolValue]==YES){
        NSMutableArray *removedIndexPathArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<numberOfCurrSubSteps; i++) {
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:i inSection:currButton.tag];
            [removedIndexPathArray addObject:indexPath1];
        }
        numberOfCurrSubSteps = 0;
        [self.routeTableView beginUpdates];
        [self.routeTableView deleteRowsAtIndexPaths:removedIndexPathArray withRowAnimation:UITableViewRowAnimationNone];
        [self.routeTableView endUpdates];
        [expandedSectionDict setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:sender.tag]];
        [sender setSelected:NO];
    }
    else {
        
        // Collapses the previous table's section if been opened already ====================================
        if ([[expandedSectionDict objectForKey:[NSNumber numberWithInt:currButton.tag]]boolValue]==YES) {
            NSMutableArray *removedIndexPathArray = [[NSMutableArray alloc]init];
            for (int i = 0; i<numberOfCurrSubSteps; i++) {
                NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:i inSection:currButton.tag];
                [removedIndexPathArray addObject:indexPath1];
            }
            numberOfCurrSubSteps = 0;
            [self.routeTableView beginUpdates];
            [self.routeTableView deleteRowsAtIndexPaths:removedIndexPathArray withRowAnimation:UITableViewRowAnimationNone];
            [self.routeTableView endUpdates];
            [expandedSectionDict setObject:[NSNumber numberWithBool:NO] forKey:[NSNumber numberWithInt:currButton.tag]];
            [currButton setSelected:NO];
        }
        
        // Expands the current table's section ==============================================================
        numberOfCurrSubSteps = [[[self.routeInstructionArray objectAtIndex:sender.tag] objectForKey:@"subInstructions"] count];
        currButton = sender;
        [expandedSectionDict setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:sender.tag]];
        NSMutableArray *addedIndexPathArray = [[NSMutableArray alloc]init];
        for (int i = 0; i<numberOfCurrSubSteps; i++) {
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:i inSection:sender.tag];
            [addedIndexPathArray addObject:indexPath1];
        }
        [self.routeTableView beginUpdates];
        [self.routeTableView insertRowsAtIndexPaths:addedIndexPathArray withRowAnimation:UITableViewRowAnimationNone];
        [self.routeTableView endUpdates];
        [sender setSelected:YES];
    }        
}
@end
