//
//  AddAPNViewControllerTableViewController.m
//  APN Changer
//
//  Created by Michael Weisman on 2014-04-28.
//  Copyright (c) 2014 Michael Weisman. All rights reserved.
//

#import "AddAPNViewControllerTableViewController.h"
#import "APNCarrier.h"
#import "CountryTableViewController.h"
#import "APNViewController.h"

static NSManagedObjectModel *managedObjectModel()
{
    static NSManagedObjectModel *model = nil;
    if (model != nil) {
        return model;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

static NSManagedObjectContext *managedObjectContext()
{
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString *STORE_TYPE = NSSQLiteStoreType;
        
        NSURL *url = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"apns" ofType:@"sqlite"]];
        
        NSError *error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:@{NSReadOnlyPersistentStoreOption: @YES} error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

@interface AddAPNViewControllerTableViewController () {
    NSDictionary *_countries;
    NSArray *_codes;
    CLLocationManager *_locationManager;
    NSString *_countryCode;
    NSManagedObjectContext *_context;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    
}
@end

@implementation AddAPNViewControllerTableViewController

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
    _context = managedObjectContext();
    
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    _locationManager.delegate = self;
    [_locationManager startUpdatingLocation];

    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"APNCarrier"];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"APNCarrier" inManagedObjectContext:_context];
    fetchRequest.resultType = NSDictionaryResultType;
    fetchRequest.propertiesToFetch = [NSArray arrayWithObject:[[entity propertiesByName] objectForKey:@"country"]];
    fetchRequest.returnsDistinctResults = YES;
    
    NSArray *dictionaries = [_context executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *countryCodes = [[NSMutableArray alloc] initWithCapacity:[dictionaries count]];
    for (NSDictionary *d in dictionaries) {
        [countryCodes addObject:d[@"country"]];
    }
    
    
    if (!_countries) {
        NSMutableDictionary *namesByCode = [NSMutableDictionary dictionary];
        NSDictionary *codesByName;
        for (NSString *code in countryCodes)
        {
            NSString *identifier = [NSLocale localeIdentifierFromComponents:@{NSLocaleCountryCode: code}];
            NSString *countryName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];
            if (countryName) namesByCode[code] = countryName;
        }
        _countries = [namesByCode copy];
        codesByName = [NSDictionary dictionaryWithObjects:[_countries allKeys] forKeys:[_countries allValues]];
        NSMutableArray *tmpSort = [[NSMutableArray alloc] initWithCapacity:[_countries count]];
        NSArray *sortedCountries = [[codesByName allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for (NSString *country in sortedCountries) {
            [tmpSort addObject:codesByName[country]];
        }
        _codes = [tmpSort copy];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows;
    if (section == 0) {
        rows = 2;
    } else {
        rows = [_codes count];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0 && indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewCarrierCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Custom Carrier Settings";
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CountryCell" forIndexPath:indexPath];
        NSString *code;
        if (indexPath.section == 0) {
            if (_countryCode) {
                code = [_countryCode lowercaseString];
            } else {
                code = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
            }
        } else {
            code = _codes[indexPath.row];
        }
        cell.imageView.image = [UIImage imageNamed:[code uppercaseString]];
        cell.textLabel.text = _countries[code];
    }
    
    return cell;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    [manager stopUpdatingLocation];
    
    CLGeocoder *g = [[CLGeocoder alloc] init];
    [g reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        _countryCode = [[placemarks firstObject] ISOcountryCode];
        [self.tableView reloadData];
    }];
}

- (IBAction)closeModal:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CountrySegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSString *code;
        if (indexPath.section == 0) {
            if (_countryCode) {
                code = [_countryCode lowercaseString];
            } else {
                code = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];
            }
        } else {
            code = _codes[indexPath.row];
        }
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"APNCarrier" inManagedObjectContext:_context];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"carrierName" ascending:YES];
        NSArray *sortDescriptors = @[sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country = %@",
                                  code];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSArray *fetchedObjects = [_context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) {
            // Handle the error.
        }

        CountryTableViewController *vc = [segue destinationViewController];
        vc.carriers = fetchedObjects;
    } else if ([segue.identifier isEqualToString:@"NewCarrierSegue"]) {
        APNViewController *vc = [segue destinationViewController];
        vc.saveButton.title = @"Add";
    }
}

@end
