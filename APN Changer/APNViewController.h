//
//  NewAPNViewController.h
//  APN Changer
//
//  Created by Michael Weisman on 10/20/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APNCarrier.h"

@interface APNViewController : UITableViewController <UITextFieldDelegate>

@property APNCarrier *carrier;
@property (weak, nonatomic) IBOutlet UITextField *carrierName;
@property (weak, nonatomic) IBOutlet UITextField *carrierDescription;
@property (weak, nonatomic) IBOutlet UITextField *apn;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction) saveCarrier:(id)sender;
- (IBAction) cancel:(id)sender;

@end
