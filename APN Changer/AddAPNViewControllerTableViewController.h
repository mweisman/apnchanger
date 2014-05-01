//
//  AddAPNViewControllerTableViewController.h
//  APN Changer
//
//  Created by Michael Weisman on 2014-04-28.
//  Copyright (c) 2014 Michael Weisman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreData/CoreData.h>

@interface AddAPNViewControllerTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
- (IBAction)closeModal:(id)sender;

@end
