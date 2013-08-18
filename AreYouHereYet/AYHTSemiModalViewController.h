//
//  AYHTSemiModalViewController.h
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/18/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import <AddressBookUI/AddressBookUI.h>
//#import <RHAddressBook/RHAddressBook.h>
#import "UIViewController+KNSemiModal.h"
#import <QuartzCore/QuartzCore.h>

@interface AYHTSemiModalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) NSMutableDictionary *peopleToContact;


- (IBAction)barButtonItemPressed:(id)sender;

@end
