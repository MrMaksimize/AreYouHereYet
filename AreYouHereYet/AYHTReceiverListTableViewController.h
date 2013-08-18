//
//  AYHTReceiverListTableViewController.h
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/17/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FlatUIKit/FlatUIKit.h>
#import <AddressBookUI/AddressBookUI.h>
@interface AYHTReceiverListTableViewController : UITableViewController <ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, strong) NSArray *peopleToContact;

@end
