//
//  AYHTSettingsViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 9/2/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTSettingsViewController.h"
#import "FUICellBackgroundView.h"
#import "FPPopoverController.h"

@interface AYHTSettingsViewController ()

@end

@implementation AYHTSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpVisuals];

    // Set NSUserDefaults Values
    //[[NSUserDefaults standardUserDefaults] setValue:self.nameTextField.text forKey:@"AYHTUserName"];
    self.nameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"AYHTUserName"];
    self.genderSegmentedControl.selectedSegmentIndex = 1;/*(NSInteger*)[[NSUserDefaults standardUserDefaults] valueForKey:@"AYHTUserGender"];*/

}

- (void)setUpVisuals
{
    [self.navBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor peterRiverColor]
                                  highlightedColor:[UIColor belizeHoleColor]
                                      cornerRadius:3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Personal Information";
    }
    return nil;
}

// TODO FIX THIS GROSS ASS SHIT
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    if (indexPath.row == 0) {
        cell = self.nameCell;
    }
    else if (indexPath.row == 1) {
        cell = self.genderCell;
    }

    if (cell == nil || !cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    /*cell = [UITableViewCell configureFlatCellWithColor:[UIColor amethystColor]
                                         selectedColor:[UIColor amethystColor]
                                                 style:UITableViewCellStyleDefault
                                       reuseIdentifier:nil];*/

    //cell.cornerRadius = 5.0f;
    //cell.separatorHeight = 2.0f;

    /*if (indexPath.row == 0 && self.nameCell == nil) {
        self.nameCell = cell;
    }
    else if (indexPath.row == 1 && self.genderCell == nil) {
        self.genderCell = cell;
    }*/


    return cell;
}

- (IBAction)segmentedControlDidSwitch:(id)sender
{
    NSLog(@"SELECTED SEGMENT INDEX F IS 1 %d", self.genderSegmentedControl.selectedSegmentIndex);
    
}

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nameTextField) {
        NSLog(@"%@", self.nameTextField.text);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.nameTextField resignFirstResponder];
    [self.genderSegmentedControl resignFirstResponder];
}

#pragma mark - FPPopoverController Delegate
- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    NSLog(@"final name %@", self.nameTextField.text);
    NSLog(@"final gender %d", self.genderSegmentedControl.selectedSegmentIndex);

    [[NSUserDefaults standardUserDefaults] setValue:self.nameTextField.text forKey:@"AYHTUserName"];
    [[NSUserDefaults standardUserDefaults] setValue:self.genderSegmentedControl forKey:@"AYHTUserGender"];
    
    
}


@end
