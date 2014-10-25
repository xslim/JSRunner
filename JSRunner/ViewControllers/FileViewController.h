//
//  FileViewController.h
//  JSRunner
//
//  Created by Taras Kalapun on 10/23/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSegmentedViewController.h"

@class RunnerViewController, EditorViewController;

@interface FileViewController : FHSegmentedViewController

@property EditorViewController *editorViewController;
@property RunnerViewController *runnerViewController;
@property UIViewController *consoleViewController;

@property (nonatomic, strong) NSString *fileName;

@end
