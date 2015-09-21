//
//  DWURunLoopWorkDistribution.h
//  RunLoopWorkDistribution
//
//  Created by Di Wu on 9/19/15.
//  Copyright © 2015 Di Wu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^DWURunLoopWorkDistributionUnit)(id info);

@interface DWURunLoopWorkDistribution : NSObject

+ (void)registerRunLoopWorkDistributionAsMainRunloopObserver:(DWURunLoopWorkDistribution *)runLoopWorkDistribution;

+ (instancetype)sharedRunLoopWorkDistribution;

- (void)addTask:(DWURunLoopWorkDistributionUnit)unit withKey:(id) key urgent:(BOOL)urgent;

@end
