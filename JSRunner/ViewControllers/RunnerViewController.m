//
//  RunnerViewController.m
//  JSRunner
//
//  Created by Taras Kalapun on 10/4/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import "RunnerViewController.h"
#import "FileController.h"

@interface RunnerViewController ()

@end

@implementation RunnerViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(runAction:)];
    
    if (self.fileName) {
        self.title = self.fileName;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeAction:) name:@"shakeNotification" object:nil];
    
    [self createForm];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)runAction:(id)sender {
    [self run];
}

- (void)setupRunner {
    if (!self.runner) {
        self.runner = [JSRunner new];
    }
    
    
    NSDictionary *d = self.formValues;
    
    self.runner.useNode     = [d[@"f.nodejs"] boolValue];
    self.runner.useJSBridge = [d[@"f.jscBindings"] boolValue];
    self.runner.useConsoleServer = [d[@"f.consoleServer"] boolValue];
    
    self.runner.injectKeyWindow = [d[@"p.keyWindow"] boolValue];
    
    [self.runner setupContext];
    
    if ([d[@"p.nc"] boolValue]) {
        UINavigationController *nc = self.navigationController;
        JSContext *context = self.runner.context;
        context[@"navigationController"] = nc;
    }
    
}

- (void)run {
    [self setupRunner];
    
    NSDictionary *d = self.formValues;
    
    if (self.script.length > 0) {
        [self.runner runJSBWithScript:self.script];
    } else if (self.fileName.length > 0) {
        NSString *path = [FileController pathForFile:self.fileName];
        [self.runner runJSBWithScriptPath:path];
    }
    
    if ([d[@"r.main"] boolValue]) {
        JSContext *context = self.runner.context;
        [context evaluateScript:@"main();"];
    }
    
}

- (void)createForm {
    TKForm *form = self.form;
    TKFormSection *section;
    TKFormRow *row;
    
    section = [form addSectionWithTitle:@"Options"];
    row = [section addRow:[TKFormRow switchWithTag:@"o.beta" title:@"Show Beta options" value:NO]];
    row.toggleRowTags = @[@"f.cordova", @"f.chrome", @"r.webView"];
    
    section = [form addSectionWithTitle:@"Frameworks"];
    [section addRow:[TKFormRow switchWithTag:@"f.nodejs" title:@"NodeJS" value:YES]];
    
    row = [section addRow:[TKFormRow switchWithTag:@"f.jscBindings" title:@"JS Core Bindings" value:YES]];
    row.details = @"JSCore to iOS Framework bindings";
    
    row = [section addRow:[TKFormRow switchWithTag:@"f.cordova" title:@"Cordova" value:NO]];
    row.hidden = YES;
    row = [section addRow:[TKFormRow switchWithTag:@"f.chrome" title:@"Chrome" value:NO]];
    row.hidden = YES;
    
    [section addRow:[TKFormRow switchWithTag:@"f.consoleServer" title:@"Debug console server" value:NO]];
    
    
    section = [form addSectionWithTitle:@"Presentation"];
    [section addRow:[TKFormRow switchWithTag:@"p.keyWindow" title:@"Inject keyWindow" value:YES]];
    [section addRow:[TKFormRow switchWithTag:@"p.nc" title:@"Inject current NC" value:YES]];
    
    section = [form addSectionWithTitle:@"Running"];
    row = [section addRow:[TKFormRow switchWithTag:@"r.webView" title:@"In WebView" value:NO]];
    row.hidden = YES;
    [section addRow:[TKFormRow switchWithTag:@"r.main" title:@"run main()" value:NO]];
    
}

- (void)shakeAction:(NSNotification *)note {
    NSLog(@"global shake");
}

@end
