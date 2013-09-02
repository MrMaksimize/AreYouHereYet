//
//  AYHTSettingsViewController.h
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 9/2/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import "UIViewController+KNSemiModal.h"

@interface AYHTSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)barButtonItemPressed:(id)sender;

@end
