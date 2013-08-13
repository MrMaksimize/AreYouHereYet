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

@interface AYHTConfRideViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel *fromVal;
@property (nonatomic, strong) IBOutlet UITextField *toVal;
@property (nonatomic, strong) IBOutlet GMSMapView *mapView;

- (IBAction)done:(id)sender;
- (IBAction)textFieldEditingDidEndOnExit:(id)sender;
//- (IBAction)cancel:(id)sender;

@end
