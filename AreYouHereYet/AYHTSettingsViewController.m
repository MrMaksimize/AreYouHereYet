//
//  AYHTSettingsViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 9/2/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTSettingsViewController.h"

@interface AYHTSettingsViewController ()

@end

@implementation AYHTSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // TODO - put NSUserDefaults stuff here.
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpVisuals];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"settingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor cloudsColor]
                                             selectedColor:[UIColor amethystColor]
                                                     style:UITableViewCellStyleDefault
                                           reuseIdentifier:CellIdentifier];
        cell.cornerRadius = 5.0f;
        cell.separatorHeight = 2.0f;
    }
    cell.textLabel.text = @"Test";
    cell.detailTextLabel.text = @"Test Detail";
    //cell.textLabel.text = @"Test";


    //cell.textLabel.te

    // Configure the cell...

    return cell;
}

@end
