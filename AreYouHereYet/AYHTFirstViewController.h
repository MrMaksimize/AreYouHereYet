//
//  AYHTFirstViewController.h
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/3/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AYHTConfRideViewController.h"


@interface AYHTFirstViewController : UIViewController <CLLocationManagerDelegate>


@property (nonatomic, strong) IBOutlet UILabel *latVal;
@property (nonatomic, strong) IBOutlet UILabel *longVal;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel; // GPS Coords default
@property (nonatomic, strong) IBOutlet UILabel *addressLabel; // GPS Coords default
@property (nonatomic, strong) IBOutlet UIButton *getLocationButton;
@property (nonatomic, strong) IBOutlet UIButton *createNewRideButton;
@property (nonatomic, strong) IBOutlet GMSMapView *mapHolderView;
@property (nonatomic, strong) IBOutlet UIView *firstStepView;

@end
