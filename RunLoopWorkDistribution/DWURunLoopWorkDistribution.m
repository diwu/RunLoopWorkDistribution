//
//  DWURunLoopWorkDistribution.m
//  RunLoopWorkDistribution
//
//  Created by Di Wu on 9/19/15.
//  Copyright © 2015 Di Wu. All rights reserved.
//

#import "DWURunLoopWorkDistribution.h"

#define DWURunLoopWorkDistribution_DEBUG 1

static NSInteger MAX_QUEUE_LENGTH = 20;

@interface DWURunLoopWorkDistribution ()

@property (nonatomic, strong) NSMutableArray *tasks;

@property (nonatomic, strong) NSMutableOrderedSet *tasksKeys;

@property (nonatomic, strong) NSMutableArray *priorities;

@property (nonatomic, strong) id previousUnitResult;

#ifdef DWURunLoopWorkDistribution_DEBUG
@property (nonatomic, assign, readwrite) NSUInteger randomNumber;

@property (nonatomic, assign) NSUInteger whatCommonModesObserverSee;

@property (nonatomic, assign) NSUInteger whatDefaultModeObserverSee;
#endif
@property (nonatomic, assign) BOOL skipNextDefaultModeCallback;

@end

@implementation DWURunLoopWorkDistribution

- (BOOL)taskAlreadyAdded: (id)key {
    if ([self.tasksKeys containsObject:key]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)addTask:(DWURunLoopWorkDistributionUnit)unit withKey:(id) key urgent:(BOOL)urgent {
    if ([self taskAlreadyAdded:key]) {
        return;
    }
    [self.tasks addObject:unit];
    [self.tasksKeys addObject:key];
    [self.priorities addObject:[NSNumber numberWithBool:urgent]];
    if (self.tasks.count > MAX_QUEUE_LENGTH) {
        [self.tasks removeObjectAtIndex:0];
        [self.tasksKeys removeObjectAtIndex:0];
        [self.priorities removeObjectAtIndex:0];
    }
}

- (instancetype)init
{
    if ((self = [super init])) {
        _tasks = [NSMutableArray array];
        _tasksKeys = [NSMutableOrderedSet orderedSet];
        _priorities = [NSMutableArray array];
        _previousUnitResult = nil;
        _skipNextDefaultModeCallback = NO;
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
    static CFRunLoopObserverRef commonModesObserver;
    static CFRunLoopObserverRef defaultModeObserver;
#if DWURunLoopWorkDistribution_DEBUG
    static CFRunLoopObserverRef beforeWaitingBeforeCACommonModesObserver;
    static CFRunLoopObserverRef beforeWaitingAfterCACommonModesObserver;
#endif
    _registerObserver(kCFRunLoopBeforeWaiting, commonModesObserver, 999, kCFRunLoopCommonModes, (__bridge void *)runLoopWorkDistribution, &commonModesRunLoopWorkDistributionCallback);
    _registerObserver(kCFRunLoopBeforeWaiting, defaultModeObserver, 1000, kCFRunLoopDefaultMode, (__bridge void *)runLoopWorkDistribution, &defaultModeRunLoopWorkDistributionCallback);
#if DWURunLoopWorkDistribution_DEBUG
    _registerObserver(kCFRunLoopBeforeWaiting, defaultModeObserver, 1000, kCFRunLoopCommonModes, (__bridge void *)runLoopWorkDistribution, &afterWaitingCallback);
    _registerObserver(kCFRunLoopBeforeWaiting, beforeWaitingBeforeCACommonModesObserver, NSIntegerMin + 999, kCFRunLoopCommonModes, (__bridge void *)runLoopWorkDistribution, &beforeWaitingBeforeCACallback);
    _registerObserver(kCFRunLoopBeforeWaiting, beforeWaitingAfterCACommonModesObserver, NSIntegerMax - 999, kCFRunLoopCommonModes, (__bridge void *)runLoopWorkDistribution, &beforeWaitingAfterCACallback);
#endif
}

static void _registerObserver(CFOptionFlags activities, CFRunLoopObserverRef observer, CFIndex order, CFStringRef mode, void *info, CFRunLoopObserverCallBack callback) {
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopObserverContext context = {
        0,           // version
        info,  // info
        &CFRetain,   // retain
        &CFRelease,  // release
        NULL         // copyDescription
    };
    
    observer = CFRunLoopObserverCreate(NULL,        // allocator
                                                  activities,  // activities
                                                  YES,         // repeats
                                                  order,
                                                  callback,  // callback
                                                  &context);   // context
    CFRunLoopAddObserver(runLoop, observer, mode);
    CFRelease(observer);
}

static void _runLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info, BOOL isInCommonModes)
{
    DWURunLoopWorkDistribution *runLoopWorkDistribution = (__bridge DWURunLoopWorkDistribution *)info;
    if (runLoopWorkDistribution.tasks.count == 0) {
        return;
    } else if (isInCommonModes && [runLoopWorkDistribution.priorities.firstObject boolValue] == NO) {
        return;
    } else if (!isInCommonModes && runLoopWorkDistribution.skipNextDefaultModeCallback) {
        runLoopWorkDistribution.skipNextDefaultModeCallback = NO;
        return;
    } else if (isInCommonModes) {
        runLoopWorkDistribution.skipNextDefaultModeCallback = YES;
    }
    DWURunLoopWorkDistributionUnit unit  = runLoopWorkDistribution.tasks.firstObject;
    runLoopWorkDistribution.previousUnitResult = unit(runLoopWorkDistribution.previousUnitResult);
    [runLoopWorkDistribution.tasks removeObjectAtIndex:0];
    [runLoopWorkDistribution.tasksKeys removeObjectAtIndex:0];
    [runLoopWorkDistribution.priorities removeObjectAtIndex:0];
#if DWURunLoopWorkDistribution_DEBUG
    NSLog(@"Task done. Remaining tasks count: %zd", runLoopWorkDistribution.tasks.count);
#endif
}

static void commonModesRunLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
#if DWURunLoopWorkDistribution_DEBUG
    DWURunLoopWorkDistribution *runLoopWorkDistribution = (__bridge DWURunLoopWorkDistribution *)info;
//    runLoopWorkDistribution.randomNumber = arc4random_uniform(NSIntegerMax);
//    runLoopWorkDistribution.whatCommonModesObserverSee = runLoopWorkDistribution.randomNumber;
    NSLog(@"common:  see random number %zd", runLoopWorkDistribution.randomNumber);
#endif
    _runLoopWorkDistributionCallback(observer, activity, info, YES);
}

static void defaultModeRunLoopWorkDistributionCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
#if DWURunLoopWorkDistribution_DEBUG
//    DWURunLoopWorkDistribution *runLoopWorkDistribution = (__bridge DWURunLoopWorkDistribution *)info;
//    runLoopWorkDistribution.whatDefaultModeObserverSee = runLoopWorkDistribution.randomNumber;
//    NSLog(@"default: current random number is %zd", runLoopWorkDistribution.randomNumber);
//    NSCAssert(runLoopWorkDistribution.whatCommonModesObserverSee == runLoopWorkDistribution.whatDefaultModeObserverSee, @"Work Unit Out of Order!");
#endif
    _runLoopWorkDistributionCallback(observer, activity, info, NO);
}

#if DWURunLoopWorkDistribution_DEBUG
static void afterWaitingCallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
//    DWURunLoopWorkDistribution *runLoopWorkDistribution = (__bridge DWURunLoopWorkDistribution *)info;
//    runLoopWorkDistribution.randomNumber = arc4random_uniform(NSIntegerMax);
}
static void beforeWaitingBeforeCACallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    DWURunLoopWorkDistribution *runLoopWorkDistribution = (__bridge DWURunLoopWorkDistribution *)info;
    runLoopWorkDistribution.randomNumber = arc4random_uniform(10000);
    NSLog(@" ");
    NSLog(@"------------------------------------------------");
    NSLog(@"common:  set random number        to %zd", runLoopWorkDistribution.randomNumber);
}
static void beforeWaitingAfterCACallback(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    DWURunLoopWorkDistribution *runLoopWorkDistribution = (__bridge DWURunLoopWorkDistribution *)info;
    NSLog(@"common:  after CA, random number    is %zd\n", runLoopWorkDistribution.randomNumber);
    NSLog(@"------------------------------------------------");
    NSLog(@" ");
    runLoopWorkDistribution.randomNumber = arc4random_uniform(10000);
}
#endif

@end
