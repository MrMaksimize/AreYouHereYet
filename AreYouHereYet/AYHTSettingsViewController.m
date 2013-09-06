//
//  AYHTSettingsViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 9/2/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTSettingsViewController.h"
#import "FPPopoverController.h"

#define kSettingsUserNameKey @"AYHTUserName"
#define kSettingsUserGenderKey @"AYHTUserGender"

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

    self.nameTextField.text = [[NSUserDefaults standardUserDefaults] valueForKey:kSettingsUserNameKey];
    self.genderSegmentedControl.selectedSegmentIndex = (NSInteger)[[NSUserDefaults standardUserDefaults] valueForKey:kSettingsUserGenderKey];

}

- (void)setUpVisuals
{
    /*[self.navBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor peterRiverColor]
                                  highlightedColor:[UIColor belizeHoleColor]
                                      cornerRadius:3];
    */

    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view setBackgroundColor:[UIColor clearColor]];

    // Gender Segmented Control:
    [self.genderSegmentedControl setImage:[UIImage imageNamed:@"male.png"] forSegmentAtIndex:0];
    [self.genderSegmentedControl setImage:[UIImage imageNamed:@"female.png"] forSegmentAtIndex:1];
    [self.genderSegmentedControl setTintColor:[UIColor peterRiverColor]];
    [self.genderSegmentedControl setBackgroundColor:[UIColor clearColor]];

    self.genderSegmentedControl.selectedColor = [UIColor peterRiverColor];
    self.genderSegmentedControl.deselectedColor = [UIColor asbestosColor];
    self.genderSegmentedControl.dividerColor = [UIColor midnightBlueColor];
    self.genderSegmentedControl.cornerRadius = 3.0;


    // Positions get figured on cell creation.

}

- (void)setUpCellElementPositionsForCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{

    CGFloat cellX = cell.frame.origin.x;
    CGFloat cellY = cell.frame.origin.y;
    CGFloat cellWidth = cell.frame.size.width;
    CGFloat cellHeight = cell.frame.size.height;
    CGFloat cellOneTenth = cell.frame.size.width * 0.1;

    
    if (indexPath.row == 0) {

        self.nameCellLabel.frame = CGRectMake(cellX + cellOneTenth / 2,
                                              cellY,
                                              cellOneTenth * 2,
                                              cellHeight);

        
        
        self.nameTextField.frame = CGRectMake(cellX + cellOneTenth + self.nameCellLabel.frame.size.width + 10,
                                              cellY,
                                              cellOneTenth * 5,
                                              cellHeight);

    }
    else if (indexPath.row == 1) {
        self.genderCellLabel.frame = CGRectMake(cellX + cellOneTenth / 2,
                                              cellY,
                                              cellOneTenth * 2,
                                              cellHeight);

        self.genderSegmentedControl.frame = CGRectMake(cellX + cellOneTenth + self.nameCellLabel.frame.size.width + 10,
                                                       cell.center.y - (self.genderSegmentedControl.frame.size.height * 0.5),
                                                       self.genderSegmentedControl.frame.size.width,
                                                       self.genderSegmentedControl.frame.size.height);
    }

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
    UITableViewCell *cell = [UITableViewCell configureFlatCellWithColor:[UIColor amethystColor]
                                                           selectedColor:[UIColor amethystColor]
                                                                   style:UITableViewCellStyleDefault
                                                         reuseIdentifier:nil];

    if (indexPath.row == 0) {
        [cell addSubview:self.nameCellLabel];
        [cell addSubview:self.nameTextField];
        
    }
    else if (indexPath.row == 1) {
        [cell addSubview:self.genderCellLabel];
        [cell addSubview:self.genderSegmentedControl];
    }

    if (cell == nil || !cell) {
        cell = [[UITableViewCell alloc] init];
    }

    [self setUpCellElementPositionsForCell:cell withIndexPath:indexPath];

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

    NSNumber *selectedIndex = [NSNumber numberWithInt:self.genderSegmentedControl.selectedSegmentIndex];

    [[NSUserDefaults standardUserDefaults] setValue:self.nameTextField.text
                                             forKey:kSettingsUserNameKey];
    
    [[NSUserDefaults standardUserDefaults] setValue:(id)selectedIndex
                                             forKey:kSettingsUserGenderKey];
    
    
}


@end
