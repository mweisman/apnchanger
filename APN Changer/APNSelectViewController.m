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
    APNChangerServer *_server;
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
    [_server stopServer];
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
    [_server stopServer];
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

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    APNViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"APNView"];
    vc.carrier = _carriers[indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.selected = NO;
    
    _server = [APNChangerServer sharedServer];
    [_server startServer];
    
    APNCarrier *theCarrier = _carriers[indexPath.row];
    NSURL *carrierURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%@/apns/apn.mobileconfig", _server.port]];
    [_server serveXMLString:theCarrier.carrierXML];
    
    [[UIApplication sharedApplication] openURL:carrierURL];
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

@end
