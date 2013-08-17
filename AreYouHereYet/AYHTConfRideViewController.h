//
//  AYHTNewRideViewController.h
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/10/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <FlatUIKit/FlatUIKit.h>
#import <SKBounceAnimation/SKBounceAnimation.h>
#import <FPPopover/FPPopoverController.h>
#import "MRMLocationTools.h"
#import "GCGeocodingService.h"
#import "MRMGoogleDistanceMatrixService.h"
#import "AYHTReceiverListTableViewController.h"



#define kFromLoc @"fromLoc"
#define kToLoc @"toLoc"
#define kFromLocAddress @"fromLocAddress"
#define kToLocAddress @"toLocAddress"


@interface AYHTConfRideViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *fromVal;
@property (nonatomic, strong) IBOutlet UITextField *toVal;
@property (nonatomic, strong) IBOutlet GMSMapView *mapView;
@property (nonatomic, strong) IBOutlet UIImageView *travelTimeIcon;
@property (nonatomic, strong) IBOutlet UIImageView *travelDistanceIcon;
@property (nonatomic, strong) IBOutlet UILabel *travelTime;
@property (nonatomic, strong) IBOutlet UILabel *travelDistance;
@property (nonatomic, strong) IBOutlet UILabel *travelFromLabel;
@property (nonatomic, strong) IBOutlet UILabel *travelToLabel;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIProgressView *completionProgressView;
@property (nonatomic, strong) IBOutlet UIButton *messageButton;
// @todo AM I doing this right by nesting the view controllers like this????
@property (nonatomic, strong) IBOutlet UIView *firstStepView;
@property (nonatomic, strong) IBOutlet UIView *secondStepView;

@property (nonatomic, strong) CLLocation *fromLoc;
@property (nonatomic, strong) CLLocation *toLoc;
@property (nonatomic, strong) NSString *fromLocAddress;
@property (nonatomic, strong) NSString *toLocAddress;

- (IBAction)textFieldEditingDidEndOnExit:(id)sender;
- (IBAction)buttonTouchUpInside:(id)sender;

//- (IBAction)cancel:(id)sender;

@end
