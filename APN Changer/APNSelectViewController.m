//
//  APNSelectViewController.m
//  APN Changer
//
//  Created by Michael Weisman on 10/19/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import "APNSelectViewController.h"
#import "APNChangerServer.h"
#import "CoreDataAccess.h"
#import "APNCarrier.h"
#import "APNViewController.h"

@interface APNSelectViewController () {
    NSMutableArray *_carriers;
}
@end

@implementation APNSelectViewController

- (void)fetchCarriers
{
    CoreDataAccess *cd = [CoreDataAccess sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"APNCarrier" inManagedObjectContext:cd.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *fetchError;
    _carriers = [NSMutableArray arrayWithArray:[cd.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError]];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self fetchCarriers];
    
    if (_carriers.count == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        APNViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"APNView"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchCarriers];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _carriers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    APNCarrier *theCarrier = (APNCarrier *)_carriers[indexPath.row];
    cell.textLabel.text = theCarrier.carrierName;
    cell.detailTextLabel.text = theCarrier.carrierDescription;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.selected = NO;
    
    UIActionSheet *whatToDoSheet = [[UIActionSheet alloc] initWithTitle:@"Open or Share APN Settings?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Install", @"Share", nil];
    
    [whatToDoSheet showInView:self.view];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CoreDataAccess *cd = [CoreDataAccess sharedInstance];
    [tableView beginUpdates];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        APNCarrier *theCarrier = _carriers[indexPath.row];
        [cd.managedObjectContext deleteObject:theCarrier];
        
        NSError *saveError;
        if (![cd.managedObjectContext save:&saveError]) {
            NSLog(@"Error saving: %@", [saveError localizedDescription]);
        }
        
        [_carriers removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    [tableView endUpdates];
}

 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    APNCarrier *carrier = _carriers[indexPath.row];
    
    if (buttonIndex == 0) {
        // Install
        APNChangerServer *server = [APNChangerServer sharedServer];
        [server startServer];
        NSURL *carrierURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%@/apns/apn.mobileconfig", server.port]];
        [server serveXMLString:carrier.carrierXML];
        
        [[UIApplication sharedApplication] openURL:carrierURL];
    } else if (buttonIndex == 1) {
        // Share
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"%@ carrier settings",carrier.carrierName], [self packageMobileConfigWithXML:carrier.carrierXML forCarrier:carrier.carrierName]] applicationActivities:nil];
        activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (NSURL *)packageMobileConfigWithXML:(NSString *)carrierXML forCarrier:(NSString *)carrierName
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mobileconfig", carrierName]];
    
    NSError *error;
    [carrierXML writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        return nil;
    }
    
    return [NSURL fileURLWithPath:filePath];
}

#pragma mark - navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showAPNSettings"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        APNCarrier *carrier = _carriers[indexPath.row];
        
        
        UINavigationController *nc = [segue destinationViewController];
        APNViewController *vc = nc.viewControllers[0];
        vc.carrier = carrier;
    }
}

@end
