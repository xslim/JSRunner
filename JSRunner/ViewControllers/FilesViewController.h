//
//  FilesViewController.h
//  JSRunner
//
//  Created by Taras Kalapun on 10/4/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilesViewController : UITableViewController

@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, assign) BOOL pickingLocation;

@end
