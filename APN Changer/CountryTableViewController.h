//
//  CountryTableViewController.h
//  APN Changer
//
//  Created by Michael Weisman on 2014-04-30.
//  Copyright (c) 2014 Michael Weisman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountryTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *carriers;

@end
