//
//  AYHTNewRideViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/10/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTConfRideViewController.h"
#define FP_POPOVER_RADIUS 0
@interface AYHTConfRideViewController ()

@end

@implementation AYHTConfRideViewController {
    MRMLocationTools *locationTool;
    CLLocation *_fromLoc;
    CLLocation *_toLoc;
    NSString *_fromLocAddress;
    NSString *_toLocAddress;
    FPPopoverController *_peoplePopover;
}

#pragma mark - View LifeCycle

// @todo - find out this gets called instead of init.

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        locationTool = [MRMLocationTools sharedLocationTool];
        _fromLoc = _toLoc = nil;
        _fromLocAddress = _toLocAddress = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Set up Map View:
    //[self.mapView.settings setAllGesturesEnabled:YES];
    
    [self setUpVisuals];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Register for Notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:kMRMLocationToolsDidUpdateLocation object:nil];
    
    // Start asking for location.
    [locationTool start];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // De Register for Notifications.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMRMLocationToolsDidUpdateLocation
                                                  object:nil];
    
    // Stop Location tool.
    [locationTool stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Visuals

-(void)setUpVisuals
{
    // Colors
    self.view.backgroundColor = [UIColor midnightBlueColor];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont: [UIFont boldFlatFontOfSize:18],
                                                                    UITextAttributeTextColor: [UIColor whiteColor]};
    [self.navigationController.navigationBar configureFlatNavigationBarWithColor:[UIColor amethystColor]];
    
    // Overall Views.
    [self.completionProgressView configureFlatProgressViewWithTrackColor:[UIColor amethystColor] progressColor:[UIColor peterRiverColor]];
    
    // Second Step View.
    [self.secondStepView setHidden:YES];
    [self.secondStepView setFrame:(CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height))];
    
    // Controls on top of map.
    UIColor *mapControlColor = [UIColor cloudsColor];
    [self.travelFromLabel setBackgroundColor:mapControlColor];
    [self.travelToLabel setBackgroundColor:mapControlColor];
    [self.fromVal setBackgroundColor:mapControlColor];
    [self.toVal setBackgroundColor:mapControlColor];
    
    // Labels on top of map.
    [self.travelDistance setBackgroundColor:mapControlColor];
    [self.travelTime setBackgroundColor:mapControlColor];
}

- (void)addBounceAnimationForView:(UIView *)viewToAnimate
                      withKeyPath:(NSString *)keyPath
                 withInitialValue:(id)initialValue
                   withFinalValue:(id)finalValue
                     withDuration:(float)animationDuration
                 withAnimationKey:(NSString *)animationKey
{
	
	SKBounceAnimation *bounceAnimation = [SKBounceAnimation animationWithKeyPath:keyPath];
	bounceAnimation.fromValue = initialValue;
	bounceAnimation.toValue = finalValue;
	bounceAnimation.duration = animationDuration;
	bounceAnimation.numberOfBounces = 0;
	//bounceAnimation.stiffness = SKBounceAnimationStiffnessLight;
	bounceAnimation.shouldOvershoot = YES;
    
	[viewToAnimate.layer addAnimation:bounceAnimation forKey:animationKey];
    
	[viewToAnimate.layer setValue:finalValue forKeyPath:keyPath];
}

#pragma mark - Actions

- (IBAction)textFieldEditingDidEndOnExit:(id)sender {
    UITextField *currentTextField = (UITextField *)sender;
    if (currentTextField.tag == 0) {
        self.toLocAddress = currentTextField.text;
        [self locationInformationDidChangeProperty:kToLocAddress];
    }
    
}

- (IBAction)buttonTouchUpInside:(id)sender {
    UIButton *buttonPressed = (UIButton*)sender;
    
    if (buttonPressed == self.nextButton) {
        NSLog(@"First Step Center X %f", self.firstStepView.center.x);
        NSLog(@"First Step Center Y %f", self.firstStepView.center.y);
        NSLog(@"First Step Origin X %f", self.firstStepView.frame.origin.x);
        NSLog(@"First Step Origin Y %f", self.firstStepView.frame.origin.y);
        NSLog(@"First Step WIDTH %f", self.firstStepView.frame.size.width);
        NSLog(@"First Step Height %f", self.firstStepView.frame.size.height);
        NSLog(@"First Step Layer Position X %f", self.firstStepView.layer.position.x);
        NSLog(@"First Step Layer Position Y %f", self.firstStepView.layer.position.y);
        NSLog(@"Second Step Center X %f", self.secondStepView.center.x);
        NSLog(@"Second Step Center Y %f", self.secondStepView.center.y);
        NSLog(@"Second Step Origin X %f", self.secondStepView.frame.origin.x);
        NSLog(@"Second Step Origin Y %f", self.secondStepView.frame.origin.y);
        NSLog(@"Second Step WIDTH %f", self.secondStepView.frame.size.width);
        NSLog(@"Second Step Height %f", self.secondStepView.frame.size.height);
        NSLog(@"Second Step Layer Position X %f", self.secondStepView.layer.position.x);
        NSLog(@"Second Step Layer Position Y %f", self.secondStepView.layer.position.y);
        [self addBounceAnimationForView:self.firstStepView
                            withKeyPath:@"position.x"
                       withInitialValue:[NSNumber numberWithFloat:self.firstStepView.center.x]
                         withFinalValue:[NSNumber numberWithFloat:self.firstStepView.center.x - 320] // @todo - think how this will affect flipped screen
                           withDuration:1.5f
                       withAnimationKey:@"firstStepRemoveAnimation"];
        
        [self.secondStepView setHidden:NO];
        
        [self addBounceAnimationForView:self.secondStepView
                            withKeyPath:@"position.x"
                       withInitialValue:[NSNumber numberWithFloat:self.secondStepView.center.x]
                         withFinalValue:[NSNumber numberWithFloat:self.secondStepView.center.x - 320]
                           withDuration:1.5f
                       withAnimationKey:@"secondStepAddAnimation"];
        
        
        
        NSLog(@"POST ANIMATION");
        NSLog(@"First Step Center X %f", self.firstStepView.center.x);
        NSLog(@"First Step Center Y %f", self.firstStepView.center.y);
        NSLog(@"First Step Origin X %f", self.firstStepView.frame.origin.x);
        NSLog(@"First Step Origin Y %f", self.firstStepView.frame.origin.y);
        NSLog(@"First Step WIDTH %f", self.firstStepView.frame.size.width);
        NSLog(@"First Step Height %f", self.firstStepView.frame.size.height);
        NSLog(@"First Step Layer Position X %f", self.firstStepView.layer.position.x);
        NSLog(@"First Step Layer Position Y %f", self.firstStepView.layer.position.y);
        NSLog(@"Second Step Center X %f", self.secondStepView.center.x);
        NSLog(@"Second Step Center Y %f", self.secondStepView.center.y);
        NSLog(@"Second Step Origin X %f", self.secondStepView.frame.origin.x);
        NSLog(@"Second Step Origin Y %f", self.secondStepView.frame.origin.y);
        NSLog(@"Second Step WIDTH %f", self.secondStepView.frame.size.width);
        NSLog(@"Second Step Height %f", self.secondStepView.frame.size.height);
        NSLog(@"Second Step Layer Position X %f", self.firstStepView.layer.position.x);
        NSLog(@"Second Step Layer Position Y %f", self.firstStepView.layer.position.y);
    }
    if (buttonPressed == self.messageButton) {
        [self setUpAndDisplayPeoplePopoverFromButton:buttonPressed];
    }
}

#pragma mark - Map Ops


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

#pragma mark - Popover
- (void)setUpAndDisplayPeoplePopoverFromButton:(UIButton *)buttonPressed
{
    /*AYHTReceiverListTableViewController *receiverTableViewController = [[AYHTReceiverListTableViewController alloc] init];
    UINavigationController *receiverTableViewNavigationController = [[UINavigationController alloc] initWithRootViewController:receiverTableViewController];
    _peoplePopover = [[FPPopoverController alloc] initWithViewController:receiverTableViewNavigationController];
    _peoplePopover.tint = FPPopoverLightGrayTint;
    _peoplePopover.border = NO;
    _peoplePopover.contentSize = CGSizeMake(300, 400);
    [_peoplePopover setShadowsHidden:YES];
    [_peoplePopover presentPopoverFromView:buttonPressed];
    //[self.navigationController pushViewController:receiverTableViewController animated:YES];*/
    
    //AYHTReceiverListTableViewController *receiverTableViewController = [[AYHTReceiverListTableViewController alloc] init];
    //[receiverTableViewController.view setFrame:CGRectMake(0, 0, 320, 200)];
    //UINavigationController *receiverTableViewNavigationController = [[UINavigationController alloc]
                                                                   //  initWithRootViewController:receiverTableViewController];
    
    // Resize so it fits well.
    //[receiverTableViewNavigationController.view setFrame:CGRectMake(0, 0, 320, 200)];
    
    /*THContactPickerViewController *contactPicker = [[THContactPickerViewController alloc] init];
    UINavigationController *contactPickerNavController = [[UINavigationController alloc]
                                                          initWithRootViewController:contactPicker];*/
    
    //[contactPickerNavController.view setFrame:CGRectMake(0, 0, 320, 400)];
    
    AYHTSemiModalViewController *controller = [[AYHTSemiModalViewController alloc] init];
    
    //UINavigationController *contactPickerNavController = [[UINavigationController alloc] initWithRootViewController:[[AYHTSemiModalViewController alloc] init]];
    
    [self presentSemiViewController:controller withOptions:@{
     KNSemiModalOptionKeys.pushParentBack    : @(YES),
     KNSemiModalOptionKeys.animationDuration : @(0.5),
     KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
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
    
    [self.travelDistanceIcon setHidden:NO];
    [self.travelDistance setHidden:NO];
    [self.travelTimeIcon setHidden:NO];
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
