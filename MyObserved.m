//
//  MyObserved.m
//  NotificatioThreading
//
//  Created by Jim on 6/11/14.
//  Copyright (c) 2014 stewartstuff.com. All rights reserved.
//

#import "MyObserved.h"

@implementation MyObserved

// Marshal the post to the main queue to get it on the main thread.
-(void)postNotification
{
    NSLog(@"in [%@ %@]", self.className, NSStringFromSelector(_cmd));
    __weak typeof(self) weakSelf = self;
    dispatch_block_t postBlock = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyObservedNotification" object:weakSelf userInfo:nil];
    };
    if ([NSThread isMainThread]) {
        postBlock();
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            postBlock();
        });
    }
}

-(id)init
{
	self = [super init];
	if ( self != nil )	{
        NSLog(@"%@ init'ed",self);
	}
	return self;
}

- (void)dealloc {
    NSLog( @"dealloc %@ on thread %@", self, [NSThread currentThread]);
}

@end
