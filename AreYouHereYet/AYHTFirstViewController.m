//
//  AYHTFirstViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/3/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTFirstViewController.h"
// This is a class extension;
@interface AYHTFirstViewController ()
- (void)updateLabels;
@end

@implementation AYHTFirstViewController {
    CLLocationManager *locationManager;
    CLLocation *location;
    BOOL updatingLocation;
    NSError *lastLocationError;
}

@synthesize messageLabel;
@synthesize latVal;
@synthesize longVal;
@synthesize addressLabel;
@synthesize getLocationButton;
@synthesize createNewRideButton;
@synthesize mapHolderView;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

- (IBAction)getLocation:(id)sender {
    [self startLocationManager];
    [self updateLabels];
}

- (IBAction)createNewRide:(id)sender {
    NSLog(@"test");
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	[self updateLabels];
    [self showMap];
}

- (void)showMap
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    NSLog(@"%@", self.mapHolderView);
    [self.mapHolderView setCamera:camera];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLabels
{
    if (location != nil) {
        self.messageLabel.text = @"GPS COORDINATES";
        self.latVal.text = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
        self.longVal.text = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
    }
    else {
        self.messageLabel.text = @"Press the Button to Start";
        self.latVal.text = @"";
        self.longVal.text = @"";
        self.addressLabel.text = @"";
    }
}

- (void)startLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
    }
}

- (void)stopLocationManager
{
    if (updatingLocation) {
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        updatingLocation = NO;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"did fail with error %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    lastLocationError = error;
    [self updateLabels];


}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"didupdatetolocation %@", locations);
    lastLocationError = nil;
    location = [locations lastObject];
    [self updateLabels];
}
@end
