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
#import "APNSigner.h"

@interface APNSelectViewController () {
    NSMutableArray *_carriers;
    APNCarrier *_selectedCarrier;
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
    
    [self fetchCarriers];
    
    if (_carriers.count == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Welcome to APN Changer" message:@"It looks like you don't have any APNs installed yet. Fill in an APN to get started." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        [self performSegueWithIdentifier:@"addAPN" sender:nil];
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
    _selectedCarrier = _carriers[indexPath.row];
    
    UIActionSheet *whatToDoSheet = [[UIActionSheet alloc] initWithTitle:@"Install or Email APN Settings?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Install", @"Email", nil];
    
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
    
    if (buttonIndex == 0) {
        // Install
        APNChangerServer *server = [APNChangerServer sharedServer];
        [server startServer];
        int carrierID = rand();
        NSURL *carrierURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%@/apns/%d", server.port, carrierID]];
        [server serveXMLString:_selectedCarrier.carrierXML forCarrier:[NSString stringWithFormat:@"%d", carrierID]];
        [server serveDownloaderForCarrier:_selectedCarrier.carrierName carrierId:[NSString stringWithFormat:@"%d", carrierID]];
        
        [[UIApplication sharedApplication] openURL:carrierURL];
    } else if (buttonIndex == 1) {
        // Email
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        picker.view.tintColor = [UIColor colorWithRed:0.050 green:0.398 blue:0.059 alpha:1.000];
        [picker setSubject:[NSString stringWithFormat:@"iPhone APN Settings for %@",_selectedCarrier.carrierName]];
        [picker addAttachmentData:[APNSigner signMobileconfig:_selectedCarrier.carrierXML] mimeType:@"application/x-apple-aspen-config" fileName:[NSString stringWithFormat:@"%@.mobileconfig", _selectedCarrier.carrierName]];
        NSString *emailBody = [NSString stringWithFormat:@"iPhone APN Settings for %@",_selectedCarrier.carrierName];
        [picker setMessageBody:emailBody isHTML:NO];
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (NSString *)packageMobileConfigWithXML:(NSString *)carrierXML forCarrier:(NSString *)carrierName
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mobileconfig", carrierName]];
    
    NSError *error;
    [carrierXML writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        return nil;
    }
    
    return filePath;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
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
