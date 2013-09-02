//
//  AYHTSemiModalViewController.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 8/18/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTContactPickerViewController.h"

@interface AYHTContactPickerViewController ()
{
    ABPeoplePickerNavigationController *picker;
}

@end

@implementation AYHTContactPickerViewController

#pragma mark - Designated Initializer

- (id)initWithContactList:(NSDictionary *)originalContactList
{
    self = [super init];
    if (self) {
        // Idk if this is right.  We'll see.
        // Copying items not to affect any ongoing text message ops.
        self.peopleToContact = [[NSMutableDictionary alloc]
                                initWithDictionary:originalContactList
                                copyItems:YES];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpVisuals];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Visuals

- (void)setUpVisuals
{
    [self.navBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor peterRiverColor]
                                  highlightedColor:[UIColor belizeHoleColor]
                                      cornerRadius:3
                                   //whenContainedIn:[self class], [ABPeoplePickerNavigationController class], nil];
     ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_peopleToContact count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"personCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell = [UITableViewCell configureFlatCellWithColor:[UIColor peterRiverColor]
                                             selectedColor:[UIColor amethystColor]
                                                     style:UITableViewCellStyleDefault
                                           reuseIdentifier:CellIdentifier];
        cell.cornerRadius = 5.0f;
        cell.separatorHeight = 2.0f;
    }
    NSLog(@"_peopleToContact at CellForRow %@", _peopleToContact);
    NSDictionary *personRecord = [[_peopleToContact allValues] objectAtIndex:indexPath.row];
    NSLog(@"index path %d, person %@", indexPath.row, personRecord);
    cell.textLabel.text = [personRecord objectForKey:@"name"];
    cell.detailTextLabel.text = [personRecord objectForKey:@"phone"];
    //cell.textLabel.text = @"Test";
    
    
    //cell.textLabel.te
    
    // Configure the cell...
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (IBAction)barButtonItemPressed:(id)sender {
    UIBarButtonItem *buttonPressed = (UIBarButtonItem *)sender;
    if (buttonPressed == self.addButton) {
        if (!picker) {
            picker = [[ABPeoplePickerNavigationController alloc] init];
            picker.peoplePickerDelegate = self;
            picker.displayedProperties = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty], nil];
            [picker.navigationBar configureFlatNavigationBarWithColor:[UIColor midnightBlueColor]];
        }
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (buttonPressed == self.doneButton) {
        // Send notification, dismiss view.
        // @todo - is sending notification the best thing here?
        // Maybe I can just directly access the prop of a parent?
        [[NSNotificationCenter defaultCenter] postNotificationName:@"peopleToContactDidChange" object:self userInfo:_peopleToContact];

        [self dismissSemiModalView];
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark - ABPeopleNavigationController Delegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSString *nameFirst = (__bridge_transfer NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *nameLast = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    NSString *name = [NSString stringWithFormat:@"%@ %@", nameFirst, nameLast];
    
    NSString *phone = nil;
    
    if (property == kABPersonPhoneProperty) {
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFIndex index = ABMultiValueGetIndexForIdentifier(phoneNumbers, identifier);
        phone = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, index);
    }
    
    NSLog(@"Name: %@, Phone: %@", name, phone);
    
    NSDictionary *personRecord = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, phone, nil]
                                                             forKeys:[NSArray arrayWithObjects:@"name", @"phone", nil]];
    
    [self.peopleToContact setObject:personRecord forKey:name];
    NSLog(@"_peopleToContact at delegate %@", _peopleToContact);
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
