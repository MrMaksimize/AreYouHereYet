//
//  AYHTNewRideViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/10/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTConfRideViewController.h"

@interface AYHTConfRideViewController ()

@end

@implementation AYHTConfRideViewController {
    NSArray *observedKeyPaths;
}

#pragma mark - View LifeCycle

// @todo - find out why this gets called instead of init.

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        _locationTool = [MRMLocationTools sharedLocationTool];
        _rideInProgress = NO;
        
        
        observedKeyPaths = [NSArray arrayWithObjects:
                             kFromLoc,
                             kToLoc,
                             kFromLocAddress,
                             kToLocAddress,
                             kTravelTimeValue,
                             nil];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpVisuals];
    
    _ride = [[AYHTRide alloc] init];
    [self registerObservers];
    
    // Start asking for location.
    
    // Todo use geofencing.
    //[_locationTool start];
    [_locationTool startWithTimeInterval:1];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // De Register for Notifications.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kMRMLocationToolsDidUpdateLocation
                                                  object:nil];
    
    // Stop Location tool.
    [_locationTool stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Observers

-(void)registerObservers
{
    // Add KVO Observers.
    
    for (NSString *keyPath in observedKeyPaths) {
        [self.ride addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionOld context:nil];
    }
    
    // Register for Notifications.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdatedLocationNotification:)
                                                 name:kMRMLocationToolsDidUpdateLocation
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:@"peopleToContactDidChange"
                                               object:nil];

}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{

    id oldValue = [change objectForKey:@"old"];
    
    // Current location updated.
    if ([keyPath isEqualToString:kFromLoc] &&
        ![self.ride locationAtKeyPath:keyPath isEqualTo:(CLLocation *)oldValue])
    {
        // Update Map
        [self updateMapAndMarkers];
    }
    // Current Location Address Updated
    if ([keyPath isEqualToString:kFromLocAddress]) {
        [self.fromVal setText:self.ride.fromLocAddress];
    }
    // To Loc Coordinates Received
    if ([keyPath isEqualToString:kToLoc] &&
        ![self.ride locationAtKeyPath:keyPath isEqualTo:(CLLocation *)oldValue]) {
        [self updateMapAndMarkers];
    }
    
    if ([keyPath isEqualToString:kTravelTimeValue]) {
        [self showTravelTime:self.ride.travelTimeString andDistance:self.ride.distanceString];
        [self dispatchTextsAsNeeded];
    }

    
    
    [self.ride refreshWithChangedKeyPath:keyPath andKnownOldValueOrNil:oldValue];
}

-(void)dispatchTextsAsNeeded
{
    if (self.ride.inProgress && [self.ride shouldDispatchText]) {
        NSLog(@"IM TEXTING BITCH");
    }

}

-(void)deRegisterObservers
{
    // Deregister for Notifications.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Remove KVO Observers.
    
    for (NSString *keyPath in observedKeyPaths) {
        [self.ride removeObserver:self forKeyPath:keyPath];
    }
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

- (void)showTravelTime:(NSString *)travelTime andDistance:(NSString *)travelDistance
{
    [self.travelDistance setText:travelDistance];
    [self.travelTime setText: travelTime];
    
    [self.travelDistanceIcon setHidden:NO];
    [self.travelDistance setHidden:NO];
    [self.travelTimeIcon setHidden:NO];
    [self.travelTime setHidden:NO];
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

- (void)transitionToViewNumber:(NSNumber *)viewNumber
{
    // @todo probably will need refactor.
    // transition only to second view for now.
    if (viewNumber == [NSNumber numberWithInt:1]) {
        [self logDataForView:self.firstStepView andStatus:@"PRE ANIMATION" andViewName:@"FIRST STEP"];
        [self logDataForView:self.secondStepView andStatus:@"PRE ANIMATION" andViewName:@"SECOND STEP"];
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
        
        
        
        [self logDataForView:self.firstStepView andStatus:@"POST ANIMATION" andViewName:@"FIRST STEP"];
        [self logDataForView:self.secondStepView andStatus:@"POST ANIMATION" andViewName:@"SECOND STEP"];
    }
}

#pragma mark - Actions

- (IBAction)textFieldEditingDidEndOnExit:(id)sender {
    UITextField *currentTextField = (UITextField *)sender;
    if (currentTextField == self.toVal) {
        self.ride.toLocAddress = currentTextField.text;
    }
    
}

- (IBAction)buttonTouchUpInside:(id)sender {
    UIButton *buttonPressed = (UIButton*)sender;
    
    if (buttonPressed == self.nextButton) {
        [self transitionToViewNumber:[NSNumber numberWithInt:1]];
    }
    else if (buttonPressed == self.messageButton) {
        [self setUpAndDisplayPeoplePicker];
    }
    else if (buttonPressed == self.startRideButton) {
        // @todo - separate method.
       
        [self initiateRide];
    }
}

- (void)initiateRide
{
    NSLog(@"INITIATING RIDE");
    self.rideInProgress = YES;
    self.ride.inProgress = YES;
    [self.ride buildNotificationTable];
    NSLog(@"notification Table %@", self.ride.notificationTable);
}

#pragma mark - Notification Receivers

- (void)didReceiveUpdatedLocationNotification:(NSNotification *)note
{
    if ([note.name isEqual: kMRMLocationToolsDidUpdateLocation]) {
        CLLocation *newLoc = [_locationTool getNewLocation];
        if (newLoc) {
            self.ride.fromLoc = newLoc;
        } else {
            NSLog(@"EMPTY LOC");
        }

    }
}



- (void)receiveNotification:(NSNotification *)note {
    if ([note.name isEqual: @"peopleToContactDidChange"]) {
        // If the people to contact was blank before.
        self.ride.peopleToContact = note.userInfo;
    }
    
}


#pragma mark - Map Ops

-(void)updateMapAndMarkers
{
    // Current location, no to location.
    if (self.ride.fromLoc && self.ride.toLoc == nil) {
        [self updateMapViewWithLocationOrBounds:self.ride.fromLoc];
        [self setMapMarkerWithLocation:self.ride.fromLoc andMarkerType:nil];
    }
    
    // No Current location, but a to location.
    else if (self.ride.toLoc && self.ride.fromLoc == nil) {
        [self updateMapViewWithLocationOrBounds:self.ride.toLoc];
        [self setMapMarkerWithLocation:self.ride.toLoc andMarkerType:nil];
    }
    
    // Both
    else {
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]
                                       initWithCoordinate:self.ride.fromLoc.coordinate
                                       coordinate:self.ride.toLoc.coordinate];
        
        [self updateMapViewWithLocationOrBounds:bounds];
        [self setMapMarkerWithLocation:self.ride.toLoc andMarkerType:nil];
        [self setMapMarkerWithLocation:self.ride.fromLoc andMarkerType:nil];
        
        
    }
    
}

- (void)updateMapViewWithLocationOrBounds:(id)updatedLocation
{
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
        // @todo - make market into a property and only updated if the change is significant enough
        GMSMarker *locMarker = [GMSMarker markerWithPosition:markerLocation.coordinate];
        locMarker.animated = YES;
        locMarker.icon = nil; // @todo change icon;
        locMarker.map = self.mapView;
    }
}


#pragma mark - PopUp
- (void)setUpAndDisplayPeoplePicker
{
    AYHTSemiModalViewController *controller = [[AYHTSemiModalViewController alloc] initWithContactList:self.ride.peopleToContact];
    
    [self presentSemiViewController:controller withOptions:@{
     KNSemiModalOptionKeys.pushParentBack    : @(YES),
     KNSemiModalOptionKeys.animationDuration : @(0.5),
     KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
     }];
}


#pragma mark - debugging

- (void)logDataForView:(UIView *)view andStatus:(NSString *)status andViewName:(NSString *)viewName
{
    NSLog(@"STATUS, %@", status);
    NSLog(@"%@ Step Center X %f", viewName, view.center.x);
    NSLog(@"%@ Step Center Y %f", viewName, view.center.y);
    NSLog(@"%@ Step Origin X %f", viewName, view.frame.origin.x);
    NSLog(@"%@ Step Origin Y %f", viewName, view.frame.origin.y);
    NSLog(@"%@ Step WIDTH %f", viewName, view.frame.size.width);
    NSLog(@"%@ Step Height %f", viewName, view.frame.size.height);
    NSLog(@"%@ Step Layer Position X %f", viewName, view.layer.position.x);
    NSLog(@"%@ Step Layer Position Y %f", viewName, view.layer.position.y);
}







@end
