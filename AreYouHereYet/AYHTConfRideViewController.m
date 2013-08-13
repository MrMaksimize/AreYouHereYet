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
    GMSGeocoder *geocoder;
}

#pragma mark - View LifeCycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationTool = [MRMLocationTools sharedLocationTool];
        geocoder = [[GMSGeocoder alloc] init];
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
        [forwardGeocoder geocodeAddress:currentTextField.text];
        NSLog(@"forwardGeo %@", forwardGeocoder.geocode);
        forwardGeocoder = nil;
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

- (void)updateMapViewWithLocation:(CLLocation *)updatedLocation
{
    NSLog(@"LOC UPDATE");
    if (updatedLocation != nil) {
        [self.mapView animateToCameraPosition:
         [GMSCameraPosition cameraWithLatitude:updatedLocation.coordinate.latitude
                                     longitude:updatedLocation.coordinate.longitude
                                          zoom:12]];
    }
    // @todo else
}

- (void)reverseGeoCodeLocation:(CLLocation *)locationToGeocode
{
    //*location = CLLocationCoordinate2DMake(locationToGeocode.coordinate.latitude, locationToGeocode.coordinate.longitude);
    NSLog(@"REVERSE GEOCODING");
    CLLocationCoordinate2D twoDlocation = CLLocationCoordinate2DMake(locationToGeocode.coordinate.latitude, locationToGeocode.coordinate.longitude);
    //NSLog(@"loc: %@", twoDlocation);
    [geocoder
     reverseGeocodeCoordinate:twoDlocation
     completionHandler:^(GMSReverseGeocodeResponse *reverseGeoResponse, NSError *reverseGeoError) {
         NSLog(@"RESPONDED");
         NSLog(@"Error: %@", reverseGeoError);
         NSLog(@"Response %@", reverseGeoResponse.firstResult);
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

#pragma mark - Notification Receiver and Router

- (void)receiveNotification:(NSNotification *)note {
    if ([note.name isEqual: kMRMLocationToolsDidUpdateLocation]) {
        CLLocation *newLoc = [[note.userInfo objectForKey:kMRMLocationToolsUpdatedLocationKey] lastObject];
        NSLog(@"%@", newLoc);
        if (newLoc) {
            [self updateMapViewWithLocation:newLoc];
        } else {
            NSLog(@"EMPTY LOC");
        }
        
    }
}



@end
