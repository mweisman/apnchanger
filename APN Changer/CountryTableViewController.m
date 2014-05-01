//
//  CountryTableViewController.m
//  APN Changer
//
//  Created by Michael Weisman on 2014-04-30.
//  Copyright (c) 2014 Michael Weisman. All rights reserved.
//

#import "CountryTableViewController.h"
#import "APNCarrier.h"
#import "APNViewController.h"

@interface CountryTableViewController ()

@end

@implementation CountryTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_carriers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"carrierInfoCell" forIndexPath:indexPath];
    
    // Configure the cell...
    APNCarrier *carrier = _carriers[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", carrier.carrierName, carrier.carrierAPN];
    cell.detailTextLabel.text = carrier.carrierDescription;
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"CarrierDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        APNCarrier *c = _carriers[indexPath.row];
        APNViewController *vc = [segue destinationViewController];
        vc.carrier = c;
        vc.saveButton.title = @"Add";
    }
}

@end
