//
//  AYHTNewRideViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/10/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTRootViewController.h"

#define kParseCloudFunctionURL @"https://api.parse.com/1/functions"
#define kParseAppID @"0MOgbOrgznYvhvbHv6bN9Zce969wp1065dsH2ujf"
#define kParseClientKey @"srDyBgrVSFieYhc2OPfymWwOYgDrFyCMyNCKwne7"

@interface AYHTRootViewController ()

@end

@implementation AYHTRootViewController {
    NSArray *observedKeyPaths;
    GMSMarker *currentLocationMarker;
    GMSMarker *destinationLocationMarker;
}

#pragma mark - View LifeCycle

- (id)init
{
    if ((self = [super init])) {
        _locationTool = [MRMLocationTools sharedLocationTool];
        _rideInProgress = NO;


        observedKeyPaths = [NSArray arrayWithObjects:
                            kFromLoc,
                            kToLoc,
                            kFromLocAddress,
                            kToLocAddress,
                            kTravelTimeValue,
                            nil];
        return self;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set Title.
    self.title = NSLocalizedString(@"Are You Here Yet?!?!", nil);
    //Set Bar Items.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"glyphiconsCogWheel.png"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(setUpAndDisplaySettings)];


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
    //if (self.ride.inProgress && [self.ride shouldDispatchText]) {
    NSLog(@"%@", self.ride.peopleToContact);
    for (NSDictionary *personDictionary in [self.ride.peopleToContact allValues]) {
        NSLog(@"%@", personDictionary);
        // FAKE VARIABLES: big TODO
        NSString *senderName = @"Maksim Pecherskiy";
        NSString *senderGender = @"M";

        NSString *pronoun = [senderGender isEqualToString:@"F"] ? @"she" : @"he";

        NSString *messageToSend = [NSString stringWithFormat:
                                   @"Hey %@! This is an automated message from %@'s AreYouHereYet App.  Just wanted to let you know %@ will be there in about %@",
                                   [personDictionary objectForKey:@"name"],
                                   senderName,
                                   pronoun,
                                   self.ride.travelTimeString];
        NSLog(@"MEssage: %@", messageToSend);
        // TODO this needs some more regex magique
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([\\D])" options:0 error:nil];
        NSString *phoneNumber = [regex
                                 stringByReplacingMatchesInString:[personDictionary objectForKey:@"phone"]
                                 options:0
                                 range:NSMakeRange(0, [[personDictionary objectForKey:@"phone"] length])
                                 withTemplate:@""];

        NSLog(@"NUMBER: %@; MESSAGE: %@", phoneNumber, messageToSend);

        //[[MRMTwilioSMS sharedSMSOperator] sendMessageToNumber:@"" withBody:messageToSend];
    }
    //[[MRMTwilioSMS sharedSMSOperator] sendMessageToNumber:@"+17736777755" withBody:@"hello"];
    //}

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

    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor wisteriaColor]
                                  highlightedColor:[UIColor amethystColor]
                                      cornerRadius:3];

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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return [self textFieldPassesValidation:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *) textField
{
    return [self textFieldPassesValidation:textField];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.toVal) {
        self.ride.toLocAddress = textField.text;
    }
}



- (BOOL)textFieldPassesValidation:(UITextField*)textField
{
    // Prevent blank entries on ToVal textfield.
    if (textField == self.toVal) {
         if (textField.text == nil || [textField.text isEqualToString:@""]) {
             return NO;
         }
    }
    return YES;
}



// Resign first responder when user touches somewhere else.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.toVal resignFirstResponder];
}

#pragma mark - Actions

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
        // Temp
        [self dispatchTextsAsNeeded];
    }

}


#pragma mark - Map Ops

-(void)updateMapAndMarkers
{
    // Current location, no to location.
    if (self.ride.fromLoc && self.ride.toLoc == nil) {
        [self updateMapViewWithLocationOrBounds:self.ride.fromLoc];
        //[self setMapMarkerWithLocation:self.ride.fromLoc andMarkerType:nil];
        currentLocationMarker = [self updatedMarkerWithOriginalMarker:currentLocationMarker
                                                         withLocation:self.ride.fromLoc
                                                          withUseCase:@"currentLocation"];
    }

    // No Current location, but a to location.
    else if (self.ride.toLoc && self.ride.fromLoc == nil) {
        [self updateMapViewWithLocationOrBounds:self.ride.toLoc];
        //[self setMapMarkerWithLocation:self.ride.toLoc andMarkerType:nil];
        destinationLocationMarker = [self updatedMarkerWithOriginalMarker:destinationLocationMarker
                                                             withLocation:self.ride.toLoc
                                                              withUseCase:@"destinationLocation"];
    }

    // Both
    else {
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc]
                                       initWithCoordinate:self.ride.fromLoc.coordinate
                                       coordinate:self.ride.toLoc.coordinate];

        [self updateMapViewWithLocationOrBounds:bounds];
        currentLocationMarker = [self updatedMarkerWithOriginalMarker:currentLocationMarker
                                                         withLocation:self.ride.fromLoc
                                                          withUseCase:@"currentLocation"];
        destinationLocationMarker = [self updatedMarkerWithOriginalMarker:destinationLocationMarker
                                                             withLocation:self.ride.toLoc
                                                              withUseCase:@"destinationLocation"];

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


- (GMSMarker *)updatedMarkerWithOriginalMarker:(GMSMarker *)marker
                                  withLocation:(CLLocation *)markerLocation
                                   withUseCase:(NSString *)useCase

{
    if (marker == nil) {
        marker = [GMSMarker markerWithPosition:markerLocation.coordinate];
    }
    else {
        [marker setPosition:markerLocation.coordinate];
    }
    if ([useCase isEqualToString:@"currentLocation"]) {
        [marker setIcon:[UIImage imageNamed:@"currentLocation@2x.png"]];
    }
    marker.animated = YES;
    marker.map = self.mapView;

    return marker;
}


#pragma mark - PopUp
- (void)setUpAndDisplayPeoplePicker
{
    AYHTContactPickerViewController *controller = [[AYHTContactPickerViewController alloc] initWithContactList:self.ride.peopleToContact];

    [self presentSemiViewController:controller
                        withOptions:@{
     KNSemiModalOptionKeys.pushParentBack    : @(YES),
     KNSemiModalOptionKeys.animationDuration : @(0.5),
     KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
     }];
}

- (void)setUpAndDisplaySettings
{
    AYHTSettingsViewController *controller = [[AYHTSettingsViewController alloc] init];
    controller.title = nil;
    FPPopoverController *popover = [[FPPopoverController alloc] initWithViewController:controller];
    // Popover properties.
    popover.contentSize = CGSizeMake(320, 200);
    popover.delegate = controller;
    popover.border = NO;
    popover.tint = FPPopoverLightGrayTint;
    popover.arrowDirection = FPPopoverNoArrow;
    popover.title = nil;
    popover.alpha = 0.8;

    [popover presentPopoverFromPoint:
     CGPointMake (
                 (self.navigationController.navigationBar.viewForBaselineLayout.frame.size.width - 27),
                 self.navigationController.navigationBar.viewForBaselineLayout.frame.size.height
                 )];
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
