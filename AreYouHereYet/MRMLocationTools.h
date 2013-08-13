//
//  MRMLocationControl.h
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/11/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kMRMLocationToolsDidUpdateLocation @"locationToolsDidUpdateLocation"
#define kMRMLocationToolsUpdatedLocationKey @"locationToolsUpdatedLocationKey"


@interface MRMLocationTools : NSObject <CLLocationManagerDelegate> {
    
    // location manager and listeners
    CLLocationManager *_locationManager;
    NSMutableArray *_listeners;
    
    // location data
    CLLocation *_newLocation;
    CLLocation *_oldLocation;
    CLHeading  *_newHeading;
    
}

// the (one and only) shared LocationDelegate

+ (MRMLocationTools*) sharedLocationTool;

// Direct access to location manager. Use this property to tweak location/heading accuracy etc.
@property (nonatomic, strong) IBOutlet CLLocationManager *locationManager;

// location data, wraps real and demo locations. If a demo is running live location updates are disabled and the locations returned are read from the route demo provider.
@property (nonatomic, strong, readonly) CLLocation *oldLocation;
@property (nonatomic, strong, readonly, getter = getNewLocation) CLLocation *newLocation;
@property (nonatomic, strong, readonly, getter = getNewHeading) CLHeading *newHeading;


// start/stop location and heading updates from CoreLocation
- (void) start;
- (void) stop;

// listening to location/heading updates
- (void) addListener:(id <CLLocationManagerDelegate>) listener;
- (void) removeListener:(id <CLLocationManagerDelegate>) listener;
@end
