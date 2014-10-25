//
//  RunnerViewController.h
//  JSRunner
//
//  Created by Taras Kalapun on 10/4/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSRunnerKit/JSRunnerKit.h>
#import <TKFormKit/TKFormKit.h>

@interface RunnerViewController : TKFormViewController
@property (nonatomic, strong) JSRunner *runner;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *script;


- (IBAction)runAction:(id)sender;
- (void)run;


@end
