//
//  ActionViewController.m
//  JSRunnerAction
//
//  Created by Taras Kalapun on 10/22/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <JSRunnerKit/JSRunnerKit.h>

@interface ActionViewController ()

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL itemFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeJavaScript]) {

                
                __typeof__(self) __weak wself = self;
                
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeJavaScript options:nil completionHandler:^(NSURL *url, NSError *error) {
                    if(url && [url isKindOfClass:[NSURL class]]) {
                        NSString *text = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            wself.title = [url lastPathComponent];
                            wself.script = text;
                        }];
                    }
                }];
                
                itemFound = YES;
                break;
            }
        }
        
        if (itemFound) {
            // We only handle one item, so stop looking for more.
            break;
        }
    }
}


- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end
