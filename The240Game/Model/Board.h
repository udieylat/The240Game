//
//  Board.h
//  The240Game
//
//  Created by Yuval on 8/12/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Board : NSObject

@property (nonatomic, readonly) NSUInteger numCols;
@property (nonatomic, readonly) NSUInteger numRows;

@property (nonatomic, readonly) NSUInteger curIndex;
@property (nonatomic, readonly) NSUInteger singlesModeFinishIndex;

@property (nonatomic, readonly) NSUInteger score;

- (void)reset;
- (void)resetLevel:(NSUInteger)startIndex;
- (BOOL)isReset; // const

- (void)load:(NSUInteger)curIndex withScore:(NSUInteger)score withBlockedIndices:(NSArray *)blockedIndices withCantFinishIndices:(NSArray *)cantFinishIndices;

- (instancetype)initWithNumCols:(NSUInteger)numCols numRows:(NSUInteger)numRows;

- (NSUInteger)maxScore; // const
+ (NSUInteger)maxScore:(NSUInteger)numCols numRows:(NSUInteger)numRows;

- (NSUInteger)maxLevelScore; // const
+ (NSUInteger)maxLevelScore:(NSUInteger)numCols numRows:(NSUInteger)numRows;

- (NSUInteger)numCells; // const
+ (NSUInteger)numCells:(NSUInteger)numCols numRows:(NSUInteger)numRows;

- (BOOL)canMove:(UISwipeGestureRecognizerDirection)direction;
- (void)move:(UISwipeGestureRecognizerDirection)direction;
- (BOOL)cellInIndexIsFree:(NSUInteger)index; // const
- (BOOL)canFinishInIndex:(NSUInteger)index; // const

- (BOOL)lost; // const
- (BOOL)levelWon; // const
- (BOOL)completedTheGame; // const
- (void)advance;
- (void)goBack:(NSUInteger)index;

- (void)setSinglesModeLevel:(NSUInteger)startIndex finishIndex:(NSUInteger)finishIndex;
- (void)setStandardMode;

@end
