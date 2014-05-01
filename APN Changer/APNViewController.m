//
//  NewAPNViewController.m
//  APN Changer
//
//  Created by Michael Weisman on 10/20/2013.
//  Copyright (c) 2013 Michael Weisman. All rights reserved.
//

#import "APNViewController.h"
#import "CoreDataAccess.h"

@interface APNViewController ()

@end

@implementation APNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!_carrier) {
        self.navigationItem.title = @"New Carrier";
    } else {
        self.navigationItem.title = _carrier.carrierName;
        _carrierDescription.text = _carrier.carrierDescription;
        _carrierName.text = _carrier.carrierName;
        _apn.text = _carrier.carrierAPN;
        _username.text = _carrier.apnUsername;
        _password.text = _carrier.apnPassword;
    }
    
    if ([_saveButton.title isEqualToString:@"Add"]) {
        _saveButton.enabled = YES;
        _carrierName.userInteractionEnabled = NO;
        _carrierDescription.userInteractionEnabled = NO;
        _apn.userInteractionEnabled = NO;
        _username.userInteractionEnabled = NO;
        _password.userInteractionEnabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) saveCarrier:(id)sender
{
    CoreDataAccess *cd = [CoreDataAccess sharedInstance];
    APNCarrier *carrierAPN;
    
    if (!_carrier || [_saveButton.title isEqualToString:@"Add"]) {
        carrierAPN = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"APNCarrier"
                                  inManagedObjectContext:cd.managedObjectContext];
    } else {
        carrierAPN = _carrier;
    }
    
    carrierAPN.carrierName = _carrierName.text;
    carrierAPN.carrierDescription = _carrierDescription.text;
    carrierAPN.carrierAPN = _apn.text;
    carrierAPN.apnUsername = _username.text;
    carrierAPN.apnPassword = _password.text;
    
    NSError *error;
    if (![cd.managedObjectContext save:&error]) {
        NSLog(@"Error saving carrier: %@", [error localizedDescription]);
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction) cancel:(id)sender
{
    if ([_saveButton.title isEqualToString:@"Add"]) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    return YES;
}

-(void)textFieldDidChange :(UITextField *)textField
{
    if ([_carrierName.text length] > 0 && [_apn.text length] > 0) {
        _saveButton.enabled = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _carrierName) {
        [_carrierDescription becomeFirstResponder];
    } else if (textField == _carrierDescription) {
        [_apn becomeFirstResponder];
    } else if (textField == _apn) {
        [_username becomeFirstResponder];
    } else if (textField == _username) {
        _password.secureTextEntry = YES;
        [_password becomeFirstResponder];
    } else if (textField == _password) {
        [self saveCarrier:nil];
        [textField resignFirstResponder];
    }
    
    return YES;
}

@end
