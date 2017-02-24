//
//  Board.m
//  The240Game
//
//  Created by Yuval on 8/12/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import "Board.h"

@interface Board()

@property (nonatomic, readwrite) NSUInteger numCols;
@property (nonatomic, readwrite) NSUInteger numRows;

@property (nonatomic, readwrite) NSUInteger curIndex;
@property (nonatomic, readwrite) NSUInteger singlesModeFinishIndex;

@property (nonatomic, readwrite) NSUInteger score;

@property (nonatomic, strong) NSMutableArray *freeCells; // of NSNumbers of type BOOL. YES means free cell
@property (nonatomic, strong) NSMutableArray *canFinishHere; // of NSNumbers of type BOOL. YES means can finish in this index

@property (nonatomic) BOOL singlesMode;

@end

@implementation Board

#define DEFAULT_NUM_COLS 4
#define DEFAULT_NUM_ROWS 4

- (NSUInteger)numCols
{
    if (!_numCols) _numCols = DEFAULT_NUM_COLS;
    return _numCols;
}

- (NSUInteger)numRows
{
    if (!_numRows) _numRows = DEFAULT_NUM_ROWS;
    return _numRows;
}

- (NSUInteger)curIndex
{
    if (!_curIndex) _curIndex = 0;
    return _curIndex;
}

- (NSUInteger)singlesModeFinishIndex
{
    if (!_singlesModeFinishIndex) _singlesModeFinishIndex = 0;
    return _singlesModeFinishIndex;
}

- (NSUInteger)score
{
    if (!_score) _score = 0;
    return _score;
}

- (BOOL)singlesMode
{
    if (!_singlesMode) _singlesMode = NO;
    return _singlesMode;
}

- (NSUInteger)startIndex
{
    return (self.numRows - 1) * self.numCols;
}

- (NSUInteger)maxScore // const
{
    return [Board maxScore:self.numCols numRows:self.numRows];
}

+ (NSUInteger)maxScore:(NSUInteger)numCols numRows:(NSUInteger)numRows;
{
    NSUInteger numItems = numCols * numRows;
    return numItems * (numItems - 1);
}

- (NSUInteger)maxLevelScore // const
{
    return [Board maxLevelScore:self.numCols numRows:self.numRows];
}

+ (NSUInteger)maxLevelScore:(NSUInteger)numCols numRows:(NSUInteger)numRows;
{
    return [Board numCells:numCols numRows:numRows] - 1;
}

- (NSUInteger)numCells // const
{
    return [Board numCells:self.numCols numRows:self.numRows];
}

+ (NSUInteger)numCells:(NSUInteger)numCols numRows:(NSUInteger)numRows
{
    return numCols * numRows;
}

- (void)resetLevel:(NSUInteger) startIndex
{
    if (!self.singlesMode) {
        self.score -= self.score % [self maxLevelScore];
    }
    
    self.curIndex = startIndex;
    
    for (int i = 0; i < [self numCells]; i++) {
        self.freeCells[i] = [NSNumber numberWithBool:YES];
    }
    
    self.freeCells[self.curIndex] = [NSNumber numberWithBool:NO];
}

- (void)reset
{
    NSAssert(!self.singlesMode, @"Can't call reset level in singles mode");
    
    self.score = 0;
    self.curIndex = [self startIndex];
    
    for (int i = 0; i < [self numCells]; i++) {
        self.freeCells[i] = [NSNumber numberWithBool:YES];
        self.canFinishHere[i] = [NSNumber numberWithBool:YES];
    }
    
    self.freeCells[self.curIndex] = [NSNumber numberWithBool:NO];
}

- (BOOL)isReset // const
{
    for (int i = 0; i < [self numCells]; i++) {
        if (![self.canFinishHere[i] boolValue]) {
            return NO;
        }
        BOOL isCurIndex = (i == self.curIndex);
        if ([self.freeCells[i] boolValue] == isCurIndex) {
            return NO;
        }
    }
    return YES;
}

- (instancetype)init
{
    self = [super init];
    
    self.freeCells = [[NSMutableArray alloc] initWithCapacity:[self numCells]];
    self.canFinishHere = [[NSMutableArray alloc] initWithCapacity:[self numCells]];
    
    [self reset];
    
    return self;
}

- (instancetype)initWithNumCols:(NSUInteger)numCols numRows:(NSUInteger)numRows
{
    self = [super init];
    
    self.numCols = numCols;
    self.numRows = numRows;
    
    self.freeCells = [[NSMutableArray alloc] initWithCapacity:[self numCells]];
    self.canFinishHere = [[NSMutableArray alloc] initWithCapacity:[self numCells]];
    
    [self reset];
    
    return self;
}

#pragma mark Moving methods

- (BOOL)canMove:(UISwipeGestureRecognizerDirection)direction
{
    NSInteger newIndex = 0;
    
    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.curIndex % self.numCols == 0) {
            return NO;
        }
        newIndex = [self oneStepLeftUnchecked];
    }
    else if (direction == UISwipeGestureRecognizerDirectionUp) {
        newIndex = [self oneStepUpUnchecked];
        if (newIndex < 0) {
            return NO;
        }
    }
    else if (direction == UISwipeGestureRecognizerDirectionRight) {
        if (self.curIndex % self.numCols == self.numCols - 1) {
            return NO;
        }
        newIndex = [self oneStepRightUnchecked];
    }
    else {
        NSAssert(direction == UISwipeGestureRecognizerDirectionDown, @"invalid direction");
        newIndex = [self oneStepDownUnchecked];
        if (newIndex >= [self numCells]) {
            return NO;
        }
    }
    
    return [self.freeCells[newIndex] boolValue]; // YES = cell is free
}

- (NSInteger)oneStepLeftUnchecked
{
    return self.curIndex - 1;
}
- (NSInteger)oneStepUpUnchecked
{
    return self.curIndex - self.numCols;
}
- (NSInteger)oneStepRightUnchecked
{
    return self.curIndex + 1;
}
- (NSInteger)oneStepDownUnchecked
{
    return self.curIndex + self.numCols;
}

- (void)moveOneStep:(UISwipeGestureRecognizerDirection)direction
{
    NSAssert([self canMove:direction], @"can't call if move is unavailable");
    
    NSInteger newIndex = 0;
    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        newIndex = [self oneStepLeftUnchecked];
    }
    else if (direction == UISwipeGestureRecognizerDirectionUp) {
        newIndex = [self oneStepUpUnchecked];
    }
    else if (direction == UISwipeGestureRecognizerDirectionRight) {
        newIndex = [self oneStepRightUnchecked];
    }
    else {
        NSAssert(direction == UISwipeGestureRecognizerDirectionDown, @"invalid direction");
        newIndex = [self oneStepDownUnchecked];
    }
    
    self.curIndex = newIndex;
    
    NSAssert([self.freeCells[self.curIndex] boolValue], @"current index must be free");
}

- (void)move:(UISwipeGestureRecognizerDirection)direction
{
    NSAssert([self canMove:direction], @"Cannot call move if can't move");
    
    while ([self canMove:direction]) {
        [self moveOneStep:direction];
    }
    
    self.freeCells[self.curIndex] = [NSNumber numberWithBool:NO];
    
    if (!self.singlesMode) {
        self.score++;
    }
}

- (BOOL)cellInIndexIsFree:(NSUInteger)index // const
{
    NSAssert(index < [self numCells], @"index not in range");
    return [self.freeCells[index] boolValue];
}

- (BOOL)canFinishInIndex:(NSUInteger)index // const
{
    NSAssert(index < [self numCells], @"index not in range");
    return [self.canFinishHere[index] boolValue];
}

- (BOOL)cantFinishInLastAvailableCells // const
{
    NSAssert(!self.singlesMode, @"Can't call cantFinishInLastAvailableCells in singles mode");
    
    for (NSUInteger index = 0; index < [self numCells]; index++) {
        // If cell is free and can finish there - OK
        if ([self.freeCells[index] boolValue] && [self canFinishInIndex:index]) {
            return NO;
        }
    }
    
    // No free cell available for finish was found
    return YES;
}

- (BOOL)lost // const
{
    if ([self levelWon]) {
        return NO;
    }
    
    if (self.singlesMode) {
        if (self.curIndex == self.singlesModeFinishIndex) {
            return YES;
        }
    }
    else {
        if ([self cantFinishInLastAvailableCells]) {
            return YES;
        }
    }
    
    return !([self canMove:UISwipeGestureRecognizerDirectionLeft] ||
    [self canMove:UISwipeGestureRecognizerDirectionUp] ||
    [self canMove:UISwipeGestureRecognizerDirectionRight] ||
    [self canMove:UISwipeGestureRecognizerDirectionDown]);
}

- (BOOL)levelWon // const
{
    // Check if there's still a free cell left - if there is, return NO, game is not won yet
    for (NSNumber *cell in self.freeCells) {
        if ([cell boolValue]) {
            return NO;
        }
    }
    
    // Singles mode:
    if (self.singlesMode) {
        return self.curIndex == self.singlesModeFinishIndex;
    }
    
    // 240 mode:
    return [self canFinishInIndex:self.curIndex];
}

- (BOOL)completedTheGame // const
{
    NSAssert(!self.singlesMode, @"Can't call completedTheGame in singles mode");
    
    if (![self levelWon]) {
        return NO;
    }
    
    for (int i = 0; i < [self numCells]; i++) {
        if ([self.canFinishHere[i] boolValue] && i != self.curIndex) {
            return NO;
        }
    }
    
    return YES;
}

- (void)advance
{
    NSAssert(!self.singlesMode, @"Can't call board advance in singles mode");
    
    self.canFinishHere[self.curIndex] = [NSNumber numberWithBool:NO];
    
    for (int i = 0; i < [self numCells]; i++) {
        self.freeCells[i] = [NSNumber numberWithBool:YES];
    }
    
    self.freeCells[self.curIndex] = [NSNumber numberWithBool:NO];
}

- (void)goBack:(NSUInteger)index
{
    NSAssert(!self.singlesMode, @"Can't call board go back in singles mode");
    
    NSAssert(index < [self numCells], @"index not in range");
    NSAssert(![self.canFinishHere[index] boolValue], @"logic error - can finish in an index that we're going back to - logic error");
    self.canFinishHere[index] = [NSNumber numberWithBool:YES];
    
    // In level 0 - abort, in level 1 - restart. Function is available from level 2 only
    NSAssert(self.score >= 2 * [self maxLevelScore], @"cannot call this function unless it's at least level 2");
    self.score -= self.score % [self maxLevelScore];
    self.score -= [self maxLevelScore];
    
    // Notice: this requires immediate resetLevel call from board (called by view controller: retry animation) - otherwise unexpected behavior
}

- (void)load:(NSUInteger)curIndex withScore:(NSUInteger)score withBlockedIndices:(NSArray *)blockedIndices withCantFinishIndices:(NSArray *)cantFinishIndices
{
    self.curIndex = curIndex;
    self.score = score;
    
    for (int i = 0; i < [self numCells]; i++) {
        self.freeCells[i] = [NSNumber numberWithBool:YES];
        self.canFinishHere[i] = [NSNumber numberWithBool:YES];
    }
    for (NSNumber *index in blockedIndices) {
        self.freeCells[[index integerValue]] = [NSNumber numberWithBool:NO];
    }
    for (NSNumber *index in cantFinishIndices) {
        self.canFinishHere[[index integerValue]] = [NSNumber numberWithBool:NO];
    }
    
    self.freeCells[self.curIndex] = [NSNumber numberWithBool:NO];
}

- (void)setSinglesModeLevel:(NSUInteger)startIndex finishIndex:(NSUInteger)finishIndex;
{
    self.singlesMode = YES;
    self.singlesModeFinishIndex = finishIndex;
    [self resetLevel:startIndex];
    
    // What more?
}

- (void)setStandardMode
{
    self.singlesMode = NO;
}

@end
