//
//  GameStatistics.h
//  240
//
//  Created by Yuval on 9/23/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameStatistics : NSObject

- (void)step;
- (void)advance:(NSUInteger)level gridSize:(NSUInteger)gridSize;
- (void)highlightEndCells:(NSUInteger)level gridSize:(NSUInteger)gridSize;
- (void)retry:(NSUInteger)level gridSize:(NSUInteger)gridSize;
- (void)goBack:(NSUInteger)fromLevel gridSize:(NSUInteger)gridSize;
- (void)restart:(NSUInteger)level gridSize:(NSUInteger)gridSize;
- (void)impossibleGame:(NSUInteger)level gridSize:(NSUInteger)gridSize;
- (void)gameCompleted:(NSUInteger)gridSize solution:(NSArray *)solution gameCompletionBoardIndex:(NSUInteger)gameCompletionBoardIndex;
- (void)toggleGridSize:(NSUInteger)toGridSize;

- (void)save;
- (void)load;

@end
