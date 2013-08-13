//
//  MRMLocationControl.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/11/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "MRMLocationTools.h"

@implementation MRMLocationTools


+ (MRMLocationTools *) sharedLocationTool
{
    static MRMLocationTools *toolInstance;
    @synchronized(self)
    {
        if (toolInstance == NULL)
        {
            toolInstance = [[self alloc] init];
        }
    }
    return toolInstance;
}


- (id) init
{
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        
        // Set app-specific locationManager properties.
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.headingFilter = kCLHeadingFilterNone;
        _locationManager.pausesLocationUpdatesAutomatically = YES;
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        _locationManager.delegate = self;
        
        _listeners = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}


#pragma mark - Location Updates

- (void) start
{
    BOOL enabled = [CLLocationManager locationServicesEnabled];
    //BOOL significant = [CLLocationManager significantLocationChangeMonitoringAvailable];
    if (enabled) {
        [_locationManager startUpdatingLocation];
        [_locationManager startUpdatingHeading];
    }
    else {
        NSLog(@"Warning: attempt to start real location updates failed.");
    }
    
}

- (void) stop
{
    [_locationManager stopUpdatingHeading];
    [_locationManager stopUpdatingLocation];
    //Release(_newLocation); _newLocation = nil;
    //Release(_oldLocation); _oldLocation = nil;
    //Release(_newHeading); _newHeading  = nil;
}

/*- (void)startWithTimeInterval:(NSTimeInterval *)updateInterval {
    _updateTimer = [NSTimer timerWithTimeInterval:*updateInterval target:self selector:@selector(updateTimerFired) userInfo:nil repeats:YES];
}*/


- (void)addListener: (id <CLLocationManagerDelegate>) listener;
{
    if (![_listeners containsObject:listener]) {
        [_listeners addObject:listener];
        if (_newLocation) {
            // Immediately update new listener with current location
            [listener locationManager:_locationManager didUpdateLocations: [NSArray arrayWithObjects:_oldLocation, _newLocation, nil]];
        }
        if (_newHeading) {
            [listener locationManager:_locationManager didUpdateHeading:_newHeading];
        }
    }
}

- (void) removeListener : (id<CLLocationManagerDelegate>) listener;
{
    [_listeners removeObject:listener];
}



#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations

{
    _newLocation = [locations lastObject];
    _oldLocation = [locations objectAtIndex:0];
    
    [_listeners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<CLLocationManagerDelegate> listener = obj;
        if ([listener respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
            [listener locationManager:manager didUpdateLocations:locations];
        }
    }];
    
    // Post notification.
    [[NSNotificationCenter defaultCenter] postNotificationName:kMRMLocationToolsDidUpdateLocation object:self userInfo:[NSDictionary dictionaryWithObject:locations forKey:kMRMLocationToolsUpdatedLocationKey]];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
    [_listeners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<CLLocationManagerDelegate> listener = obj;
        if ([listener respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
            [listener locationManager:manager didUpdateHeading:newHeading];
        }
    }];
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [_listeners enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id<CLLocationManagerDelegate> listener = obj;
        if ([listener respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [listener locationManager:manager didFailWithError:error];
        }
    }];
    
}

@end
