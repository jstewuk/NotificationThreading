//
//  MyObserver.m
//  NotificatioThreading
//
//  Created by Jim on 6/11/14.
//  Copyright (c) 2014 stewartstuff.com. All rights reserved.
//

#import "MyObserver.h"

@implementation MyObserver

-(void)observedNotification:(NSNotification *)notification
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t workBlock = ^{
        typeof (self) strongSelf = weakSelf;
        NSLog( @"begin %@ on thread: %@", strongSelf, [NSThread currentThread]);
        sleep( 3 );
        NSLog( @"end %@", strongSelf );
    };
    // This captures self and prevents the obj from being dealloc'ed.
    //   there is still a small vulnerability period, where another thread could start the deallocation process
    //   between the time this method gets called and the in block strong reference is created
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0L), workBlock);
}

-(id)init
{
	self = [super init];
	if ( self != nil )
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( observedNotification: ) name:@"MyObservedNotification" object:nil];
        NSLog(@"%@ init'ed",self);
	}
	return self;
}

-(void)dealloc
{
    NSLog(@"in [%@ %@]", self.className, NSStringFromSelector(_cmd));
    
    // Executing on a thread different than the notification posting thread while the notification is being handled
    // will cause a crash, since it starts tearing down this object before the notifications are run to completion.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	  NSLog( @"dealloc %@ on thread %@", self, [NSThread currentThread] );
    
    // Works because removeObserver will allow all notifications on the same thread to run before finishing dealloc
    // NB this has to be sync, since when dealloc exit the system finishes object teardown
    // if it could be called on the notification thread need to guard against deadlock
    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        NSLog(@"calling removeObserver");
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        NSLog( @"removeObserver called on thread %@", [NSThread currentThread] );
//    });
}

@end
