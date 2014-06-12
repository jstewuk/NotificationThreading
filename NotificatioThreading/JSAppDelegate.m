//
//  JSAppDelegate.m
//  NotificatioThreading
//
//  Created by Jim on 6/11/14.
//  Copyright (c) 2014 stewartstuff.com. All rights reserved.
//

#import "JSAppDelegate.h"
#import "MyObserver.h"
#import "MyObserved.h"

@implementation JSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    __block MyObserver *myObserver = [[MyObserver alloc] init];
    MyObserved *myObserved = [[MyObserved alloc] init];
	NSLog( @"myObserver %@", myObserver );
    
    // Post the notification which has a delay built in, to allow time to trigger deallocation of the server object
    // on a different queue/thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [myObserved postNotification];
    });
    // Set myObserver to nil on a background thread to get deallocation to happen before notification is posted
    NSLog(@"myObserver is about to be set to nil");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), ^{
         myObserver = nil;
    });
}

@end
