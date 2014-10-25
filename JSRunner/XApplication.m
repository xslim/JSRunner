//
//  XApplication.m
//  JSRunner
//
//  Created by Taras Kalapun on 10/24/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import "XApplication.h"

@implementation XApplication

- (void)sendEvent:(UIEvent *)event
{
    if ( event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake ) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shakeNotification" object:nil];
    }
    
    [super sendEvent:event];
}

@end
