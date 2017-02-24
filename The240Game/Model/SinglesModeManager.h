//
//  SinglesModeManager.h
//  240
//
//  Created by Yuval on 10/17/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SinglesModeManager : NSObject

@property (nonatomic, readonly) NSUInteger curLevel;
@property (nonatomic, readonly) NSUInteger maxLevel;

- (BOOL)advanceCheckGameCompleted;
- (void)retry; // For statistics
- (NSUInteger)numLevels; // const
- (NSUInteger)numLevels4x4; // const
- (NSArray *)getLevel; // const
- (NSUInteger)getLevelStartIndex; // const
- (NSUInteger)getLevelFinishIndex; // const
- (BOOL)levelGridIs4x4; // const
- (void)nextLevel;
- (void)prevLevel;
- (void)lastLevel;
- (void)firstLevel;

- (void)load;

- (void)hack; // remove

@end
