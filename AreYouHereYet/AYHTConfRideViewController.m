//
//  AYHTNewRideViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/10/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTConfRideViewController.h"
#import "GCGeocodingService.h"
#import "MRMLocationTools.h"

@interface AYHTConfRideViewController ()

@end

@implementation AYHTConfRideViewController {
    MRMLocationTools *locationTool;
    CLLocation *fromLoc;
    CLLocation *toLoc;
}

#pragma mark - View LifeCycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationTool = [MRMLocationTools sharedLocationTool];
        //[self addObserver:self forKeyPath:@"toLoc" options:NSKeyValueObservingOptionNew context: nil];
    }
    return self;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpMapView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:kMRMLocationToolsDidUpdateLocation object:nil];
    [locationTool start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self tearDownMapView];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMRMLocationToolsDidUpdateLocation
                                                  object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)done:(id)sender
{
    NSLog(@"Done");
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textFieldEditingDidEndOnExit:(id)sender{
    UITextField *currentTextField = (UITextField *)sender;
    if (currentTextField.tag == 0) {
        GCGeocodingService *forwardGeocoder = [[GCGeocodingService alloc] init];
        [forwardGeocoder geocodeAddress:currentTextField.text withCallback:@selector(didReceiveForwardGeocode:) withDelegate:self];
    }
    
}

#pragma mark - Map Ops

- (void)setUpMapView
{
    //self.mapView.myLocationEnabled = YES;
    [self.mapView.settings setAllGesturesEnabled:YES];
    //[self.mapView.settings setMyLocationButton:YES];
    //[self.mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context: nil];
}

- (void)tearDownMapView
{
    //[self.mapView removeObserver:self forKeyPath:@"myLocation"];
}

- (void)didReceiveForwardGeocode:(NSDictionary *)geocode {
    toLoc = [[CLLocation alloc] initWithLatitude:[[geocode objectForKey:@"lat"] doubleValue]
                                       longitude:[[geocode objectForKey:@"lng"] doubleValue]];
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:fromLoc.coordinate coordinate:toLoc.coordinate];
    GMSCameraUpdate *updated = [GMSCameraUpdate fitBounds:bounds];
    [self updateMapMarkerWithLocation:toLoc andMarkerType:nil];
    [self.mapView animateWithCameraUpdate:updated];
}

- (void)updateMapViewWithLocation:(CLLocation *)updatedLocation
{
    NSLog(@"LOC UPDATE");
    if (updatedLocation != nil) {
        [self.mapView animateToCameraPosition:
         [GMSCameraPosition cameraWithLatitude:updatedLocation.coordinate.latitude
                                     longitude:updatedLocation.coordinate.longitude
                                          zoom:12]];
        GMSMarker *myLocMarker = [GMSMarker markerWithPosition:updatedLocation.coordinate];
        myLocMarker.animated = YES;
        myLocMarker.icon = nil; // @todo change icon;
        myLocMarker.map = self.mapView;
    }
    // @todo else
}

- (void)updateMapMarkerWithLocation:(CLLocation *)updatedLocation
                      andMarkerType:(NSString *)markerType
{
    if (updatedLocation != nil) {
        GMSMarker *locMarker = [GMSMarker markerWithPosition:updatedLocation.coordinate];
        locMarker.animated = YES;
        locMarker.icon = nil; // @todo change icon;
        locMarker.map = self.mapView;
    }
}

- (void)reverseGeoCodeLocation:(CLLocation *)locationToGeocode
{
    NSLog(@"REVERSE GEOCODING");
    GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
    CLLocationCoordinate2D twoDlocation = CLLocationCoordinate2DMake(locationToGeocode.coordinate.latitude, locationToGeocode.coordinate.longitude);
    [geocoder reverseGeocodeCoordinate:twoDlocation
                     completionHandler:
     ^(GMSReverseGeocodeResponse *reverseGeoResponse, NSError *reverseGeoError) {
        if (reverseGeoResponse.firstResult == nil || reverseGeoError != nil) {
             [self.fromVal setText:[NSString stringWithString:reverseGeoError.localizedFailureReason]];
         }
         else {
             [self.fromVal setText:[NSString stringWithFormat:@"%@, %@", reverseGeoResponse.firstResult.addressLine1, reverseGeoResponse.firstResult.addressLine2]];
             NSLog(@"%@", self.fromVal.text);
         }
         
    }];
}

#pragma mark - Observers

/*- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
    {
        NSLog(@"Observer Triggered, location: %@", self.mapView.myLocation);
        [self updateMapViewWithLocation:self.mapView.myLocation];
        [self reverseGeoCodeLocation:self.mapView.myLocation];
    }
}*/

/*- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"toLoc"]) {
        NSLog(@"Observer Triggered");
    }
}*/



#pragma mark - Notification Receiver and Router

- (void)receiveNotification:(NSNotification *)note {
    if ([note.name isEqual: kMRMLocationToolsDidUpdateLocation]) {
        CLLocation *newLoc = [[note.userInfo objectForKey:kMRMLocationToolsUpdatedLocationKey] lastObject];
        NSLog(@"%@", newLoc);
        if (newLoc) {
            [self updateMapViewWithLocation:newLoc];
            [self updateMapMarkerWithLocation:newLoc andMarkerType:nil];
            [self reverseGeoCodeLocation:newLoc];
            fromLoc = newLoc;
            [locationTool stop];
        } else {
            NSLog(@"EMPTY LOC");
        }
        
    }
}



@end
