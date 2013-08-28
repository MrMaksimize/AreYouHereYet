//
//  AYHTTravelPathModel.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/21/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTRide.h"

@implementation AYHTRide
{
    //GMSGeocoder *geocoder;
}

- (id)init
{
    self = [super init];
    
    _fromLoc = nil;
    _toLoc = nil;
    _fromLocAddress = nil;
    _toLocAddress = nil;
    _inProgress = NO;
    _distanceString = nil;
    _distanceValue = nil;
    _travelTimeValue = nil;
    _travelTimeString = nil;
    
    // Clear out people to contact dictionary on launch.
    _peopleToContact = [[NSDictionary alloc] init];
    
    _notificationTable = nil;
    _lastNotificationIndex = 0;
    
    [self registerObservers];
    
    return self;
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"matrixServiceDidRespond"
                                               object:nil];
}

- (BOOL)locationAtKeyPath:(NSString *)keyPath isEqualTo:(CLLocation *)location
{
    CLLocation *locationOnObject = [self valueForKeyPath:keyPath];
    if (!locationOnObject || !location) {
        return NO;
    }
    CLLocationDistance distance = [locationOnObject distanceFromLocation:location];
    if (distance < 10) {
        return YES;
    }
    return NO;
}

- (void)refreshWithChangedKeyPath:(NSString *)keyPathOrNil andKnownOldValueOrNil:(id)oldValue
{
    if ([keyPathOrNil isEqualToString:kFromLoc] &&
        ![self locationAtKeyPath:keyPathOrNil isEqualTo:(CLLocation *)oldValue]) {
        if (!_inProgress) {
            [self updateProperty:kFromLocAddress];
        }
        else {
            self.fromLocAddress = @"Current Location";
        }
    }
    
    if ([keyPathOrNil isEqualToString:kToLocAddress] &&
        ![self.toLocAddress isEqualToString:(NSString *)oldValue]) {
        [self updateProperty:kToLoc];
    }
    
    if ([keyPathOrNil isEqualToString:kToLoc] || [keyPathOrNil isEqualToString:kFromLoc]) {
        if (self.toLoc && self.fromLoc &&
            ![self locationAtKeyPath:keyPathOrNil isEqualTo:(CLLocation *)oldValue]) {
            [self updateDistanceAndTravelTime];
            [self registerObservers];
        }
    }
}

- (void)buildNotificationTable
{
    NSMutableArray *tempNotificationTable = [[NSMutableArray alloc] init];
    int initialValue = [self.travelTimeValue intValue];
    int currentValue = initialValue;
    // @todo #define 180
    while (currentValue > 180) {
        currentValue = (int)currentValue / 2;
        [tempNotificationTable addObject:[NSNumber numberWithInt:currentValue]];
    }
    self.notificationTable = [NSArray arrayWithArray:tempNotificationTable];
}

- (BOOL)shouldDispatchText
{
    if (self.inProgress && [self.notificationTable count] > _lastNotificationIndex) {
        if (self.travelTimeValue <= [self.notificationTable objectAtIndex:_lastNotificationIndex]) {
            _lastNotificationIndex = _lastNotificationIndex + 1;
            return YES;
        }
    }

    return NO;
}

- (void)updateProperty:(NSString *)property
{
    NSLog(@"updating %@", property);
    if ([property isEqualToString:kFromLocAddress]) {
        [self reverseGeoCodeLocation:self.fromLoc];
    }
    if ([property isEqualToString:kToLoc]) {
        GCGeocodingService *forwardGeocoder = [[GCGeocodingService alloc] init];
        [forwardGeocoder geocodeAddress:self.toLocAddress
                           withCallback:@selector(didReceiveForwardGeocode:)
                           withDelegate:self];
    }

}

- (void)updateDistanceAndTravelTime
{
    MRMGoogleDistanceMatrixService *matrixService = [[MRMGoogleDistanceMatrixService alloc]
                                                     initWithNotificationName:@"matrixServiceDidRespond"];
    
    [matrixService distanceFromOrigin:
     [NSString stringWithFormat:@"%f,%f", self.fromLoc.coordinate.latitude, self.fromLoc.coordinate.longitude]
                        toDestination:
     [NSString stringWithFormat:@"%f,%f", self.toLoc.coordinate.latitude, self.toLoc.coordinate.longitude]];
}



- (void)reverseGeoCodeLocation:(CLLocation *)locationToGeocode
{
    CLLocationCoordinate2D coordinatesToGeoCode =
        CLLocationCoordinate2DMake(locationToGeocode.coordinate.latitude, locationToGeocode.coordinate.longitude);
    
    GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
    
    [geocoder reverseGeocodeCoordinate:coordinatesToGeoCode
                     completionHandler:
     ^(GMSReverseGeocodeResponse *reverseGeoResponse, NSError *reverseGeoError) {
         if (reverseGeoResponse.firstResult == nil || reverseGeoError != nil) {
             self.fromLocAddress = reverseGeoError.localizedFailureReason;
         }
         else {
             NSString *reverseGeocodedFromAddress =
             [NSString stringWithFormat:@"%@, %@",
              reverseGeoResponse.firstResult.addressLine1,
              reverseGeoResponse.firstResult.addressLine2];
             
             self.fromLocAddress = reverseGeocodedFromAddress;
         }
     }];
}

// @todo - this should go away and be a notification callback.

- (void)didReceiveForwardGeocode:(NSDictionary *)geocode {
    self.toLoc = [[CLLocation alloc] initWithLatitude:[[geocode objectForKey:@"lat"] doubleValue]
                                        longitude:[[geocode objectForKey:@"lng"] doubleValue]];
}


- (void)receiveNotification:(NSNotification *)note {
    if ([note.name isEqual: @"matrixServiceDidRespond"]) {
        self.distanceValue = [[[note.userInfo objectForKey:@"elements"]
                          objectForKey:@"distance"] objectForKey:@"value"];
        self.distanceString = [[[note.userInfo objectForKey:@"elements"]
                           objectForKey:@"distance"] objectForKey:@"text"];
        self.travelTimeValue = [[[note.userInfo objectForKey:@"elements"]
                          objectForKey:@"duration"] objectForKey:@"value"];
        self.travelTimeString = [[[note.userInfo objectForKey:@"elements"]
                           objectForKey:@"duration"] objectForKey:@"text"];
    }
}

@end
