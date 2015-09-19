//
//  DWURunLoopWorkDistribution.m
//  RunLoopWorkDistribution
//
//  Created by Di Wu on 9/19/15.
//  Copyright © 2015 Di Wu. All rights reserved.
//

#import "DWURunLoopWorkDistribution.h"

static NSInteger MAX_QUEUE_LENGTH = 20;

static NSInteger MAX_CACHE_SIZE = 40;

@interface DWURunLoopWorkDistribution ()

@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, strong) NSMutableOrderedSet *tasksKeys;

@end

@implementation DWURunLoopWorkDistribution

- (BOOL)taskAlreadyAdded: (id)key {
    if ([self.tasksKeys containsObject:key]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)addTask:(void(^)(void))task withKey:(id) key{
    if ([self taskAlreadyAdded:key]) {
        return;
    }
    [self.tasks addObject:task];
    [self.tasksKeys addObject:key];
    if (self.tasks.count > MAX_QUEUE_LENGTH) {
        [self.tasks removeObjectAtIndex:0];
        [self.tasksKeys removeObjectAtIndex:0];
    }
}

- (instancetype)init
{
    if ((self = [super init])) {
        _tasks = [NSMutableArray array];
        _tasksKeys = [NSMutableOrderedSet orderedSet];
    }
    return self;
}

+ (instancetype)sharedRunLoopWorkDistribution {
    static DWURunLoopWorkDistribution *singleton;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[DWURunLoopWorkDistribution alloc] init];
        [self registerRunLoopWorkDistributionAsMainRunloopObserver:singleton];
    });
    return singleton;
}

+ (void)registerRunLoopWorkDistributionAsMainRunloopObserver:(DWURunLoopWorkDistribution *)runLoopWorkDistribution {
    static CFRunLoopObserverRef observer;
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFOptionFlags activities = (kCFRunLoopBeforeWaiting | // before the run loop starts sleeping
                                kCFRunLoopExit);          // before exiting a runloop run
    CFRunLoopObserverContext context = {
        0,           // version
        (__bridge void *)runLoopWorkDistribution,  // info
        &CFRetain,   // retain
        &CFRelease,  // release
        NULL         // copyDescription
    };
    
    observer = CFRunLoopObserverCreate(NULL,        // allocator
                                       activities,  // activities
                                       YES,         // repeats
                                       1000,     // order after CA transaction commits
                                       &_runLoopWorkDistributionCallback,  // callback
                                       &context);   // context
    CFRunLoopAddObserver(runLoop, observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
}

static void _runLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info)
{
    DWURunLoopWorkDistribution *runLoopWorkDistribution = (__bridge DWURunLoopWorkDistribution *)info;
    while (runLoopWorkDistribution.tasks.count) {
        void (^task)()  = runLoopWorkDistribution.tasks.lastObject;
        task();
        [runLoopWorkDistribution.tasks removeLastObject];
        [runLoopWorkDistribution.tasksKeys removeObjectAtIndex:runLoopWorkDistribution.tasksKeys.count-1];
        break;
    }
}

@end
