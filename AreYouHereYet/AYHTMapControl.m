//
//  AYHTMapControl.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/10/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

// DEPRECATED
#import "AYHTMapControl.h"

@implementation AYHTMapControl {
    CLLocationManager *locationManager;
    CLLocation *location;
    BOOL updatingLocation;
    NSError *lastLocationError;
}


- (id)init
{
    if (self) {
        locationManager = [[CLLocationManager alloc] init];
    }
    return self;
}

@end