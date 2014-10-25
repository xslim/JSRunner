//
//  FileViewController.m
//  JSRunner
//
//  Created by Taras Kalapun on 10/23/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import "FileViewController.h"
#import "EditorViewController.h"
#import "RunnerViewController.h"

@interface FileViewController ()

@end

@implementation FileViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.editorViewController = [EditorViewController new];
    self.runnerViewController = [RunnerViewController new];
    self.consoleViewController = [UIViewController new];
    
    self.runnerViewController.fileName = self.fileName;
    
    [self setViewControllers:@[self.runnerViewController, self.editorViewController, self.consoleViewController]
                      titles:@[@"Run", @"Edit", @"Console"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
