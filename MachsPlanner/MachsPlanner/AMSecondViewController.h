//
//  AMSecondViewController.h
//  MachsPlanner
//
//  Created by Alvis Mach on 5/07/13.
//  Copyright (c) 2013 themachsystem. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapView.h"
#import "QBPopupMenu.h"
#define kGOOGLE_API_KEY @"AIzaSyB_GHIH-8MC6-_9IsoOYxfTzmYTpSmqDRM"
typedef enum
{
    URL_Connection_SearchAddress = 0,
    URL_Connection_GetDirections,
} URLConnection_Type;

@interface AMSecondViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate,NSURLConnectionDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    CLLocationManager *locationManager;
    float longitude, latitude, destLatitude, destLongitude;
    CLLocationCoordinate2D currentCentre;
    CLLocationCoordinate2D foundLocation;
    int currenDist;
    UIButton *prevBtnClicked;
    BOOL firstLaunch;
    BOOL isPlaceAutocomplete;
    IBOutlet UIButton *trackingButton;
    IBOutlet UISearchBar *placeSearchBar;
    NSMutableData *receivedGeoData;
    URLConnection_Type connectionType;
}

@property (strong, nonatomic) MKMapView *planMapView;
@property (nonatomic, strong) UITableView *googleResultTable;
@property (nonatomic, strong) NSMutableArray *googleResponseArray;
@property (nonatomic, strong) QBPopupMenu *popupMenu;

- (IBAction)googlePlace_onClicked:(id)sender;
- (IBAction)trackinguserLocation_onClicked:(id)sender;

@end
