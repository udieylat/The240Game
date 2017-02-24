//
//  GameInfo.h
//  The240Game
//
//  Created by Yuval on 9/17/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Board.h"

@interface GameInfo : NSObject

- (void)save;
- (BOOL)loadInfoFromFile;
- (void)loadBoardFromInfo:(Board *)board;

- (void)deleteGameInfoFile;

- (void)updateInfoFromBoard:(Board *)board;
- (void)resetLevel:(Board *)board;
- (void)restart:(Board *)board;
- (void)advance:(Board *)board;
- (void)goBack:(Board *)board;
- (void)addEmptyBoardInfo;
- (void)toggleGridSize;

- (NSUInteger)bestScore;
- (NSUInteger)levelStartIndex;
- (NSUInteger)prevLevelStartIndex;
- (NSArray *)solution;
- (NSUInteger)curGridSize;
- (NSUInteger)maxGridSize;

@end
