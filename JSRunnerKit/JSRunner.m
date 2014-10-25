//
//  JSRunner.m
//  JSRunner
//
//  Created by Taras Kalapun on 10/22/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import "JSRunner.h"

#import <Nodelike/Nodelike.h>
#import <JavaScriptBridgeLib/JavaScriptBridge.h>

#import <CocoaLumberjack/CocoaLumberjack.h>

#if DEBUG
#import <IGJavaScriptConsole/IGJavaScriptConsole.h>
#endif

@interface JSRunner ()

#if DEBUG
@property (nonatomic, strong) IGJavaScriptConsoleServer *consoleServer;
#endif

@end

@implementation JSRunner

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [self setupRunner];
        self.useNode = YES;
        self.useJSBridge = YES;
        
        self.injectKeyWindow = YES;
    }
    return self;
}

- (JSContext *)context {
    if (!_context) {
        [self setupContext];
    }
    return _context;
}

- (void)setupContext {
    
    if (!self.docPath) {
        NSString *appGroupId = @"group.JSRunner";
        NSURL *appGroupDirectoryPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroupId];
        self.docPath = appGroupDirectoryPath.path;
    }
    
    JSContext *context = nil;
        
    if (self.useJSBridge) {
        context = [JSBScriptingSupport globalContext];
        
        
        //    [context addScriptingSupport:@"CoreLocation"];
        //    [context addScriptingSupport:@"MapKit"];
        //    [context addScriptingSupport:@"PassKit"];
        //    [context addScriptingSupport:@"AssetsLibrary"];
        //    [context addScriptingSupport:@"Accounts"];
        //    [context addScriptingSupport:@"Social"];
        //
        //    [context addScriptingSupport:@"SpriteKit"];
        
    }
    
    if (!context) {
        context = [[JSContext alloc] init];
        context.exceptionHandler = ^(JSContext *context, JSValue *value) {
            NSLog(@"%@", value);
        };
    }
    
    if (self.useNode) {
        NSMutableDictionary *env = [NLContext getEnv];
        env[@"HOME"] = self.docPath;
        // FIXME: Remove later?
        env[@"NODE_PATH"] = self.docPath;
        
        [NLContext attachToContext:context];
    }

    
    [context evaluateScript:@"var console = {}"];
    context[@"console"][@"log"] = ^(NSString *message) {
        NSLog(@"Javascript log: %@", message);
    };
    
    context[@"alert"] = ^(NSString *message) {
        [[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    };
    
    if (self.injectKeyWindow) {
        [context evaluateScript:@"var keyWindow = {}"];
        context[@"keyWindow"] = [UIApplication sharedApplication].keyWindow;
    }
    
    
#if DEBUG
    if (self.useConsoleServer) {
        NSError* error;
        self.consoleServer = [[IGJavaScriptConsoleServer alloc] initWithContext:context
                                                                       language:IGJavaScriptConsoleServerLanguageJavaScript];
        self.consoleServer.port = 3300;
        if (![self.consoleServer start:&error]) {
            DDLogError(@"error: %@", error);
        }
    }
#endif
    
    
    NSString *utiljsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"_utils" ofType:@"js"];
    NSString *utiljs = [NSString stringWithContentsOfFile:utiljsPath encoding:NSUTF8StringEncoding error:nil];
    if (utiljs) {
        [context evaluateScript:utiljs];
    }
    
    self.context = context;
    
}

- (void)runJSBWithScriptPath:(NSString *)path {
    NSString *script = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self runJSBWithScript:script];
}


- (void)runJSBWithScript:(NSString *)script {
    if (!script) {
        return;
    }
    [self.context evaluateScript:script];
}

@end
