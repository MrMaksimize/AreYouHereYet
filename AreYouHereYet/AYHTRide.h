//
//  AYHTTravelPathModel.h
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/21/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GCGeocodingService.h"
#import "MRMGoogleDistanceMatrixService.h"

#define kFromLoc @"fromLoc"
#define kToLoc @"toLoc"
#define kFromLocAddress @"fromLocAddress"
#define kToLocAddress @"toLocAddress"
#define kDistanceString @"distanceString"
#define kTravelTimeValue @"travelTimeValue"

@interface AYHTRide : NSObject

@property (nonatomic, strong) CLLocation *fromLoc;
@property (nonatomic, strong) CLLocation *toLoc;
@property (nonatomic, strong) NSString *fromLocAddress;
@property (nonatomic, strong) NSString *toLocAddress;
@property (nonatomic, strong) NSNumber *distanceValue;
@property (nonatomic, strong) NSString *distanceString;
@property (nonatomic, strong) NSNumber *travelTimeValue;
@property (nonatomic, strong) NSString *travelTimeString;

// Main place of record for people to contact.
@property (nonatomic, strong) NSDictionary *peopleToContact;
@property (nonatomic, strong) NSArray *notificationTable; 


@property BOOL inProgress;
@property int  lastNotificationIndex;

- (void)refreshWithChangedKeyPath:(NSString *)keyPathOrNil andKnownOldValueOrNil:(id)oldValue;
- (void)buildNotificationTable;
- (BOOL)locationAtKeyPath:(NSString *)keyPath isEqualTo:(CLLocation *)location;
- (BOOL)shouldDispatchText;

@end
