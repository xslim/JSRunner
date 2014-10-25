//
//  JSRunner.h
//  JSRunner
//
//  Created by Taras Kalapun on 10/22/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface JSRunner : NSObject

@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) NSString *docPath;

@property (nonatomic, assign) BOOL useNode;
@property (nonatomic, assign) BOOL useJSBridge;
@property (nonatomic, assign) BOOL useConsoleServer;

@property (nonatomic, assign) BOOL injectKeyWindow;

- (void)setupContext;
- (void)runJSBWithScriptPath:(NSString *)path;
- (void)runJSBWithScript:(NSString *)script;

@end
