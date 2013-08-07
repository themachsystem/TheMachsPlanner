//
//  MapViewController.m
//
//  Created by sugartin.info on 2/7/10.
//  Copyright 2010 http://www.sugartin.info. All rights reserved.
//

#import "MapView.h"
#import "AMAppDelegate.h"
@interface MapView()

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded;
-(void) updateRouteView;
-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) from to: (CLLocationCoordinate2D) to;
-(void) centerMap;

@end

@implementation MapView

@synthesize lineColor;

- (id) initWithFrame:(CGRect) frame
{
	self = [super initWithFrame:frame];
	if (self != nil) {
		if(myMapView) {
			myMapView.delegate=nil;
			[myMapView release];
			myMapView=nil;
		}
		myMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		myMapView.showsUserLocation = YES;
		[myMapView setDelegate:self];
		[self addSubview:myMapView];
		routeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, myMapView.frame.size.width, myMapView.frame.size.height)];
		routeView.userInteractionEnabled = NO;
		[myMapView addSubview:routeView];
		
		self.lineColor = [UIColor blueColor];
	}
	return self;
}

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	NSInteger lat=0;
	NSInteger lng=0;
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[[NSNumber alloc] initWithFloat:lat * 1e-5] autorelease];
		NSNumber *longitude = [[[NSNumber alloc] initWithFloat:lng * 1e-5] autorelease];
		printf("[%f,", [latitude doubleValue]);
		printf("%f]", [longitude doubleValue]);
		CLLocation *loc = [[[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]] autorelease];
		[array addObject:loc];
	}
	
	return array;
}

-(NSArray*) calculateRoutesFrom:(CLLocationCoordinate2D) f to: (CLLocationCoordinate2D) t {
	NSString* saddr = [NSString stringWithFormat:@"%f,%f", f.latitude, f.longitude];
	NSString* daddr = [NSString stringWithFormat:@"%f,%f", t.latitude, t.longitude];
	NSString* apiUrlStr = nil;
    AMAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    if (appDelegate.travelMode) {
        apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@&dirflg=%@", saddr, daddr,appDelegate.travelMode];
    }
    else {
	 apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@", saddr, daddr];
    }
    appDelegate.travelMode = @"";
	NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
	NSLog(@"api url: %@", apiUrl);
	NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl];
	NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
	
	return [self decodePolyLine:[encodedPoints mutableCopy]];
}

-(void) centerMap {
	if(routes.count==0) return;
	MKCoordinateRegion region;

	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLocation = [routes objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[myMapView setRegion:region animated:YES];
}

-(void) showRouteFrom: (Place*) f to:(Place*) t {
	
	if(routes) {
		[myMapView removeAnnotations:[myMapView annotations]];
		[routes release];
	}
	
	PlaceMark* from = [[[PlaceMark alloc] initWithPlace:f] autorelease];
	PlaceMark* to = [[[PlaceMark alloc] initWithPlace:t] autorelease];
	[myMapView addAnnotation:from];
	[myMapView addAnnotation:to];
	
	routes = [[self calculateRoutesFrom:from.coordinate to:to.coordinate] retain];
	
	[self updateRouteView];
	[self centerMap];
}

-(void) updateRouteView {
	
	if (routes.count==0) {
		UIAlertView *av=[[[UIAlertView alloc] initWithTitle:@"Message" message:@"Path is not possible for these locations" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[av show];
		routeView.image=nil;
		return;
	}
	
	CGContextRef context = 	CGBitmapContextCreate(nil, 
												  routeView.frame.size.width, 
												  routeView.frame.size.height, 
												  8, 
												  4 * routeView.frame.size.width,
												  CGColorSpaceCreateDeviceRGB(),
												  kCGImageAlphaPremultipliedLast);
	
	CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
	CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
	CGContextSetLineWidth(context, 7.0);
	
	for(int i = 0; i < routes.count; i++) {
		CLLocation* location = [routes objectAtIndex:i];
		CGPoint point = [myMapView convertCoordinate:location.coordinate toPointToView:routeView];
		
		if(i == 0) {
			CGContextMoveToPoint(context, point.x, routeView.frame.size.height - point.y);
		} else {
			CGContextAddLineToPoint(context, point.x, routeView.frame.size.height - point.y);
		}
	}
	
	CGContextStrokePath(context);
	
	CGImageRef image = CGBitmapContextCreateImage(context);
	UIImage* img = [UIImage imageWithCGImage:image];
	
	routeView.image = img;
	CGContextRelease(context);

}

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	routeView.hidden = YES;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	[self updateRouteView];
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}
- (void)passUserLocation:(CLLocationCoordinate2D)location{
    userLocation = location;
}
- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if([annotation isKindOfClass: [MKUserLocation class]])
        return nil;
    
    
    MKPinAnnotationView *pinView = nil;
    
    static NSString *defaultPinID = @"Place to be";
    pinView = (MKPinAnnotationView *)[myMapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:defaultPinID];
    if ((annotation.coordinate.latitude == userLocation.latitude)&&(annotation.coordinate.longitude==userLocation.longitude)) {
        pinView.pinColor = MKPinAnnotationColorPurple;
    }
    else {
        pinView.pinColor = MKPinAnnotationColorGreen;
    }
    pinView.canShowCallout = YES;
    pinView.animatesDrop = YES;
    return pinView; 
}

- (void)dealloc {
	if(routes) {
		[routes release];
	}
	[myMapView release];
	[routeView release];
    [super dealloc];
}

@end
