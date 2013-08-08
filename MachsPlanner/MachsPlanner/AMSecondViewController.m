//
//  AMSecondViewController.m
//  MachsPlanner
//
//  Created by Alvis Mach on 5/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import "AMSecondViewController.h"
#import "MapPoint.h"
#import "SVProgressHUD.h"
#import "JSON.h"
#import "AMDirectionViewController.h"
#import "Place.h"
#import "AMAppDelegate.h"
#import "SVProgressHUD.h"
#define METERS_PER_MILE 1609.344
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface AMSecondViewController ()
@end

@implementation AMSecondViewController
@synthesize planMapView = _planMapView;
@synthesize googleResultTable = _googleResultTable;
@synthesize googleResponseArray = _googleResponseArray;
@synthesize popupMenu = _popupMenu;
@synthesize destLatitude = _destLatitude;
@synthesize destLongitude = _destLongitude;
@synthesize destionationTitle = _destionationTitle;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locationManager startUpdatingLocation];
    firstLaunch=YES;
    [self performSelector:@selector(moveToCurrentLocation) withObject:nil afterDelay:.5];
    
    for (UIView *view in placeSearchBar.subviews){
        if ([view isKindOfClass: [UITextField class]]) {
            UITextField *tf = (UITextField *)view;
            tf.delegate = self;
            break;
        }
    }
}

- (void)moveToCurrentLocation{
    CLLocationCoordinate2D userLocation = CLLocationCoordinate2DMake(latitude,longitude);
    [self moveToCoordinate:userLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    latitude = location.coordinate.latitude;
    longitude =  location.coordinate.longitude;
    
}
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views

{    

    MKAnnotationView *annotationView = [views objectAtIndex:0];

    id<MKAnnotation> mp = [annotationView annotation];
    CLLocationCoordinate2D centre = [mv centerCoordinate];

    MKCoordinateRegion region;
    if (firstLaunch) {
        region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);
        //firstLaunch=NO;
    }else {
        //Set the center point to the visible region of the map and change the radius to match the search radius passed to the Google query string.
        region = MKCoordinateRegionMakeWithDistance(centre,currenDist,currenDist);
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ( [NSStringFromClass( [annotation class]) isEqualToString:@"MKUserLocation"] ) {
        return nil;
    }
    
    
    NSString* identifier = @"MyAnnotation";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (pinView)
    {
        [pinView removeFromSuperview];
        pinView = nil;
    }
    
    if(pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                   reuseIdentifier:identifier];
        if ((annotation.coordinate.longitude==foundLocation.longitude)&&(annotation.coordinate.latitude==foundLocation.latitude)) {
            pinView.pinColor= MKPinAnnotationColorPurple;
        }
        pinView.enabled = YES;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [detailButton setBackgroundImage:[UIImage imageNamed:@"go-direction.jpg"] forState:UIControlStateNormal];
        pinView.rightCalloutAccessoryView=detailButton;
        
    }
    return pinView;
}

- (void)getDirections:(id)sender{
    QBPopupMenuItem *popupItem = (QBPopupMenuItem*)sender;
    [SVProgressHUD showWithStatus:@"Processing route maps"];
    connectionType = URL_Connection_GetDirections;
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSMutableString *urlString = nil;
    if ([popupItem.title isEqualToString:@"Public Transport"]) 
    {
        double seconds = [NSDate timeIntervalSinceReferenceDate];
        urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&departure_time=%0.0f&mode=transit",latitude,longitude,_destLatitude,_destLongitude,seconds];
        appDelegate.travelMode = @"r";
        
    }
    else if ([popupItem.title isEqualToString:@"Walking"]) {
        urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=walking",latitude,longitude,_destLatitude,_destLongitude];
        appDelegate.travelMode = @"w";
    }
    else if ([popupItem.title isEqualToString:@"Biking"]) {
        urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=bicycling",latitude,longitude,_destLatitude,_destLongitude];
        appDelegate.travelMode = @"b";
        
        
    }
    else if ([popupItem.title isEqualToString:@"Driving"]){
        urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%f,%f&destination=%f,%f&sensor=true&mode=driving",latitude,longitude,_destLatitude,_destLongitude];
    }
    
    
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{

}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self createPopupMenu];
    [self.popupMenu showInView:self.planMapView atPoint:CGPointMake(mapView.center.x, view.frame.origin.y)];

    _destLatitude = view.annotation.coordinate.latitude;
    _destLongitude = view.annotation.coordinate.longitude;    
    
}
- (void)createPopupMenu{
    QBPopupMenu *popupMenu = [[QBPopupMenu alloc] init];
    QBPopupMenuItem *item1 = [QBPopupMenuItem itemWithTitle:@"Public Transport" image:[UIImage imageNamed:@"train-icon.png"] target:self action:@selector(getDirections:)];
    item1.width = 100;
    
    QBPopupMenuItem *item2 = [QBPopupMenuItem itemWithTitle:@"Walking" image:[UIImage imageNamed:@"walking-icon.png"] target:self action:@selector(getDirections:)];
    item2.width = 64;

    QBPopupMenuItem *item3 = [QBPopupMenuItem itemWithTitle:@"Driving" image:[UIImage imageNamed:@"driving-icon.png"] target:self action:@selector(getDirections:)];
    item3.width = 64;

    QBPopupMenuItem *item4 = [QBPopupMenuItem itemWithTitle:@"Biking" image:[UIImage imageNamed:@"biking-icon.png"] target:self action:@selector(getDirections:)];
    item4.width = 64;

    popupMenu.items = [NSArray arrayWithObjects:item1, item2, item3,item4, nil];
    self.popupMenu = popupMenu;
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //Get the east and west points on the map so we calculate the distance (zoom level) of the current map view.
    MKMapRect mRect = self.planMapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set our current distance instance variable.
    currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    //Set our current centre point on the map instance variable.
    currentCentre = self.planMapView.centerCoordinate;
}


- (void)moveToCoordinate:(CLLocationCoordinate2D)location
{
//    CLLocationCoordinate2D loc = [location MKCoordinateValue];
    self.planMapView.showsUserLocation = YES;
    //self.mapView.delegate = self;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [self.planMapView setRegion:viewRegion animated:YES];

}

-(void) queryGooglePlaces: (NSString *) googleType
{
    [SVProgressHUD showWithStatus:@"Processing information"];
    // Build the url string we are going to sent to Google. NOTE: The kGOOGLE_API_KEY is a constant which should contain your own API key that you can obtain from Google. See this link for more info:
    // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&types=%@&sensor=true&key=%@", currentCentre.latitude, currentCentre.longitude, [NSString stringWithFormat:@"%i", currenDist/2], googleType, kGOOGLE_API_KEY];
    //Formulate the string as URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    if (!responseData)
    {
        [SVProgressHUD showErrorWithStatus:@"Error while fetching data"];
        return;
    }
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
    
    //Plot the data in the places array onto the map with the plotPostions method.
    [self plotPositions:places];
    
    
}

- (void)plotPositions:(NSArray *)data
{
    //Remove any existing custom annotations but not the user location blue dot.
    for (id<MKAnnotation> annotation in self.planMapView.annotations)
    {
        if (([annotation isKindOfClass:[MapPoint class]])&&((annotation.coordinate.longitude!=foundLocation.longitude)&&(annotation.coordinate.latitude!=foundLocation.latitude)))
        {
            [self.planMapView removeAnnotation:annotation];
        }
    }
    
    
    //Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++)
    {
        
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [data objectAtIndex:i];
        
        //There is a specific NSDictionary object that gives us location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        
        
        //Get our name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        
        //Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        //Create a new annotiation.
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:vicinity coordinate:placeCoord];
        
        
        [self.planMapView addAnnotation:placeObject];
    }
    if (([data count]==0)&&(firstLaunch==NO)) {
        [SVProgressHUD showErrorWithStatus:@"Sorry! The place you search is not around here. Please go somewhere else!"];
    }
    else if (([data count]!=0)&&(firstLaunch==NO)){
        [SVProgressHUD dismiss];
        firstLaunch = NO;
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    if (self.googleResultTable) {
        [self.googleResultTable removeFromSuperview];
        self.googleResultTable =nil;
    }}

#pragma Seach Bars delegate methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
 
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length]>1) {
        [self autocompletePlace:searchBar.text];
    }
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    //Perform the JSON query.
    if (self.googleResultTable) {
        [self.googleResultTable removeFromSuperview];
        self.googleResultTable =nil;
    }
    [self searchCoordinatesForAddress:[searchBar text]];
    [self.view endEditing:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) aSearchBar {
    if (self.googleResultTable) {
        [self.googleResultTable removeFromSuperview];
        self.googleResultTable =nil;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    //if we only try and resignFirstResponder on textField or searchBar,
    //the keyboard will not dissapear (at least not on iPad)!
    [self performSelector:@selector(searchBarCancelButtonClicked:) withObject:placeSearchBar afterDelay: 0.1];
    return YES;
}
// Query google's place autocomplete
- (void)autocompletePlace:(NSString*)place{
    [SVProgressHUD showWithStatus:@"Searching"];
    connectionType = URL_Connection_SearchAddress;
    isPlaceAutocomplete = YES;

    //Build the string to Query Google Maps.
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];

    NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&components=country:%@&sensor=true&key=%@",place,countryCode,kGOOGLE_API_KEY];
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void) searchCoordinatesForAddress:(NSString *)inAddress
{
    [SVProgressHUD showWithStatus:@"Searching"];
    connectionType = URL_Connection_SearchAddress;
    isPlaceAutocomplete = NO;

    //Build the string to Query Google Maps.
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",inAddress];
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Setup and start an async download.
    //Note that we should test for reachability!.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}
-(void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    if (receivedGeoData) 
    {
        receivedGeoData = nil;
        receivedGeoData = [[NSMutableData alloc] init];
    }
    else
        receivedGeoData = [[NSMutableData alloc] init];
    
}

//It's called when the results of [[NSURLConnection alloc] initWithRequest:request delegate:self] come back.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{   
    //    NSDictionary *dict = [XMLReader dictionaryForXMLData:data error:&err];
    
    [receivedGeoData appendData:data]; 
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *jsonResult = [[NSString alloc] initWithData:receivedGeoData encoding:NSUTF8StringEncoding];
    NSError *theError = NULL;
    NSDictionary *dictionary = [jsonResult JSONValue];
    switch (connectionType) {
        case URL_Connection_SearchAddress:
        {
            if (isPlaceAutocomplete) {
                NSArray *resultArray = [dictionary objectForKey:@"predictions"];
                if ([resultArray count]<1) {
                    [SVProgressHUD showErrorWithStatus:@"Unable to find location"];
                    break;
                }
                if (self.googleResponseArray) {
                    self.googleResponseArray=nil;
                }
                self.googleResponseArray = [[NSMutableArray alloc] init];
                for (NSDictionary *subArray in resultArray) {
                    [self.googleResponseArray addObject:[subArray objectForKey:@"description"]];
                }
                [SVProgressHUD dismiss];
                [self showTableResult:placeSearchBar];
                break;
            }
            NSArray *resultArray = [dictionary objectForKey:@"results"];
            if ([resultArray count]<1) {
                [SVProgressHUD showErrorWithStatus:@"Unable to find location"];
                break;
            }
            NSDictionary *resultDict = [resultArray objectAtIndex:0];
            
            CLLocationCoordinate2D placeCoord;
            
            //Set the lat and long.
            placeCoord.longitude = [[[[resultDict objectForKey:@"geometry"] objectForKey:@"location"]objectForKey:@"lng"] doubleValue];
            placeCoord.latitude = [[[[resultDict objectForKey:@"geometry"] objectForKey:@"location"]objectForKey:@"lat"] doubleValue];
            NSString *address = [NSString stringWithFormat:@"%@",[resultDict objectForKey:@"formatted_address"]];
            
            MapPoint *placeObject = [[MapPoint alloc] initWithName:(_destionationTitle)?:@"The found location! " address:address coordinate:placeCoord];
            foundLocation = placeCoord;
            [self.planMapView addAnnotation:placeObject];
            
            [self moveToCoordinate:placeCoord];
            [SVProgressHUD dismiss];
            break;
        }
        case URL_Connection_GetDirections:
        {
            NSArray *resultArray = [dictionary objectForKey:@"routes"];
            if ([resultArray count]<1) {
                [SVProgressHUD showErrorWithStatus:@"Unable to get directions"];
                break;
            }
            NSDictionary *resultDict = [resultArray objectAtIndex:0];
            NSArray *legRouteArray = [resultDict objectForKey:@"legs"];
            NSString *distance = [NSString stringWithFormat:@"%@",[[[legRouteArray objectAtIndex:0] objectForKey:@"distance"] objectForKey:@"text"]];
            NSString *howLong = [NSString stringWithFormat:@"%@",[[[legRouteArray objectAtIndex:0] objectForKey:@"duration"] objectForKey:@"text"]];
            AMDirectionViewController *directionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AMDirectionViewController"];
            directionVC.destionationTitle = _destionationTitle; 
            [directionVC passDistance:distance duration:howLong routeArray:legRouteArray];
            [self presentViewController:directionVC animated:YES completion:^{
            [SVProgressHUD dismiss];
            }];
            break;
        }

        default:
            break;
    }
}

-(void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{    
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@",error]];
}

- (void)createTableView{
    [self.googleResultTable reloadData];
    self.googleResultTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 60, 300, 44*[self.googleResponseArray count])];
    self.googleResultTable.dataSource = self;
    self.googleResultTable.delegate = self;
    self.googleResultTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.googleResultTable.backgroundColor = [UIColor grayColor];
    [self.googleResultTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)showTableResult:(UISearchBar*)sender{
    if (self.googleResultTable) {
        [self.googleResultTable removeFromSuperview];
        self.googleResultTable = nil;
    }
    [self createTableView];
    [self.view addSubview:self.googleResultTable];
}
#pragma mark - Table View Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.googleResponseArray count];
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
    
    
    cell.textLabel.font = [UIFont fontWithName:@"Thonburi" size:20];
    cell.textLabel.textColor = [UIColor blackColor];
    if ([self.googleResponseArray count] > 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.googleResponseArray objectAtIndex:indexPath.row]];
        cell.textLabel.font = [UIFont fontWithName:@"Thonburi" size:12];
        cell.textLabel.tag = indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [self.googleResultTable cellForRowAtIndexPath:indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:indexPath.row];
    placeSearchBar.text = label.text;
    [self searchBarSearchButtonClicked:placeSearchBar];
    [self.googleResultTable removeFromSuperview];
    self.googleResultTable =nil;
}

#pragma IBAction methods
- (IBAction)googlePlace_onClicked:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (prevBtnClicked!=btn) {
        [btn setSelected:YES];
//        [btn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
        [prevBtnClicked setSelected:NO];
//        [prevBtnClicked setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
//        [btn setBackgroundColor:[UIColor darkGrayColor]];
//        [prevBtnClicked setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    }
    NSString *textSearch;     
    switch (btn.tag) {
        case 1:
            textSearch = @"atm";
            break;
        case 2:
            textSearch = @"lodging";
            break;
        case 3:
            textSearch = @"night_club";
            break;
        case 4:
            textSearch = @"shopping_mall";
            break;
        default:
            textSearch = @"restaurant";
            break;
    }
    firstLaunch=NO;
    prevBtnClicked = btn;
    [self queryGooglePlaces:textSearch];
}

- (IBAction)trackinguserLocation_onClicked:(id)sender {
    [self moveToCurrentLocation];
}

@end
