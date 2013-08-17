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
#import "MRMGoogleDistanceMatrixService.h"

@interface AYHTConfRideViewController ()

@end

@implementation AYHTConfRideViewController {
    MRMLocationTools *locationTool;
    CLLocation *_fromLoc;
    CLLocation *_toLoc;
    NSString *_fromLocAddress;
    NSString *_toLocAddress;
}

#pragma mark - View LifeCycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationTool = [MRMLocationTools sharedLocationTool];
        _fromLoc = _toLoc = nil;
        _fromLocAddress = _toLocAddress = nil;
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
        self.toLocAddress = currentTextField.text;
        [self locationInformationDidChangeProperty:kToLocAddress];
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



- (void)updateMapViewWithLocationOrBounds:(id)updatedLocation
{
    NSLog(@"LOC UPDATE");
    if (updatedLocation != nil) {
        if ([updatedLocation isKindOfClass:[CLLocation class]]) {
            CLLocation *targetLoc = (CLLocation *)updatedLocation;
            GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate setTarget:targetLoc.coordinate zoom:12];
            [self.mapView animateWithCameraUpdate:cameraUpdate];
        }
        else if ([updatedLocation isKindOfClass:[GMSCoordinateBounds class]]) {
            GMSCoordinateBounds *targetBounds = (GMSCoordinateBounds *)updatedLocation;
            GMSCameraUpdate *updated = [GMSCameraUpdate fitBounds:targetBounds];
            [self.mapView animateWithCameraUpdate:updated];

        }
        
    }
    // @todo else
}


- (void)setMapMarkerWithLocation:(CLLocation *)markerLocation
                      andMarkerType:(NSString *)markerType
{
    if (markerLocation != nil) {
        GMSMarker *locMarker = [GMSMarker markerWithPosition:markerLocation.coordinate];
        locMarker.animated = YES;
        locMarker.icon = nil; // @todo change icon;
        locMarker.map = self.mapView;
    }
}

#pragma mark - Geocoding

- (void)reverseGeoCodeLocation:(CLLocation *)locationToGeocode
{
    NSLog(@"REVERSE GEOCODING");
    GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
    CLLocationCoordinate2D coordinatesToGeoCode = CLLocationCoordinate2DMake(locationToGeocode.coordinate.latitude, locationToGeocode.coordinate.longitude);
    [geocoder reverseGeocodeCoordinate:coordinatesToGeoCode
                     completionHandler:
     ^(GMSReverseGeocodeResponse *reverseGeoResponse, NSError *reverseGeoError) {
        if (reverseGeoResponse.firstResult == nil || reverseGeoError != nil) {
             [self.fromVal setText:[NSString stringWithString:reverseGeoError.localizedFailureReason]];
         }
         else {
             NSString *reverseGeocodedFromAddress = [NSString stringWithFormat:@"%@, %@", reverseGeoResponse.firstResult.addressLine1, reverseGeoResponse.firstResult.addressLine2];
             
             // Set the instance variable.
             _fromLocAddress = reverseGeocodedFromAddress;
             // Trigger change notifier.
             [self locationInformationDidChangeProperty:kFromLocAddress];
         }
         
    }];
}


#pragma mark - Notification Receiver and Router

- (void)didReceiveForwardGeocode:(NSDictionary *)geocode {
    _toLoc = [[CLLocation alloc] initWithLatitude:[[geocode objectForKey:@"lat"] doubleValue]
                                        longitude:[[geocode objectForKey:@"lng"] doubleValue]];
    [self locationInformationDidChangeProperty:kToLoc];
}


- (void)receiveNotification:(NSNotification *)note {
    if ([note.name isEqual: kMRMLocationToolsDidUpdateLocation]) {
        CLLocation *newLoc = [[note.userInfo objectForKey:kMRMLocationToolsUpdatedLocationKey] lastObject];
        if (newLoc) {
            self.fromLoc = newLoc;
            [self locationInformationDidChangeProperty:kFromLoc];
        } else {
            NSLog(@"EMPTY LOC");
        }
        
    }
    if ([note.name isEqual: @"distanceCalculated"]) {
        [self.travelDistance setText:[[[note.userInfo objectForKey:@"elements"] objectForKey:@"distance"] objectForKey:@"text"]];
        [self.travelTime setText: [[[note.userInfo objectForKey:@"elements"] objectForKey:@"duration"] objectForKey:@"text"]];

        [self showTravelTime:[[[note.userInfo objectForKey:@"elements"] objectForKey:@"distance"] objectForKey:@"text"]
                 andDistance:[[[note.userInfo objectForKey:@"elements"] objectForKey:@"duration"] objectForKey:@"text"]];
    }
}

- (void)showTravelTime:(NSString *)travelTime andDistance:(NSString *)travelDistance
{
    [self.travelDistance setText:travelDistance];
    [self.travelTime setText: travelTime];

    [self.travelDistanceLabel setHidden:NO];
    [self.travelDistance setHidden:NO];
    [self.travelTimeLabel setHidden:NO];
    [self.travelTime setHidden:NO];
}


- (void)locationInformationDidChangeProperty:(NSString *)property {
    NSLog(@"TRIGGERED %@", property);
    if ([property isEqualToString:kToLoc]) {
        NSLog(@"%@ --- %f", property, self.toLoc.coordinate.latitude);
        if (self.toLoc) {
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:_fromLoc.coordinate
                                                                               coordinate:_toLoc.coordinate];
            
            [self updateMapViewWithLocationOrBounds:bounds];
            [self setMapMarkerWithLocation:_toLoc andMarkerType:nil];

            MRMGoogleDistanceMatrixService *matrixService = [[MRMGoogleDistanceMatrixService alloc]
                                                             initWithNotificationName:@"distanceCalculated"];
            [matrixService distanceFromOrigin:[NSString stringWithFormat:@"%f,%f", _fromLoc.coordinate.latitude, _fromLoc.coordinate.longitude]
                                toDestination:[NSString stringWithFormat:@"%f,%f", _toLoc.coordinate.latitude, _toLoc.coordinate.longitude]];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(receiveNotification:)
                                                         name:@"distanceCalculated"
                                                       object:nil];
        }
    }
    else if ([property isEqualToString:kToLocAddress]) {
        NSLog(@"%@ --- %@", property, self.toLocAddress);
        if (self.toLocAddress) {
            GCGeocodingService *forwardGeocoder = [[GCGeocodingService alloc] init];
            [forwardGeocoder geocodeAddress:self.toLocAddress
                               withCallback:@selector(didReceiveForwardGeocode:)
                               withDelegate:self];
        }
    }
    else if ([property isEqualToString:kFromLoc]) {
        NSLog(@"%@ --- %f", property, self.fromLoc.coordinate.latitude);
        if (self.fromLoc) {
            [self updateMapViewWithLocationOrBounds:self.fromLoc];
            [self setMapMarkerWithLocation:self.fromLoc andMarkerType:nil];
            [self reverseGeoCodeLocation:self.fromLoc];
            [locationTool stop];
        }

    }
    else if ([property isEqualToString:kFromLocAddress]) {
        NSLog(@"%@ --- %@", property, self.fromLocAddress);
        if (self.fromLocAddress) {
            // Set the label.
            [self.fromVal setText:self.fromLocAddress];
        }
    }
    
}






@end
