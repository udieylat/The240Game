//
//  GameInfo.m
//  The240Game
//
//  Created by Yuval on 9/17/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import "Flurry.h"

#import "GameInfo.h"

@interface GameInfo()

@property (nonatomic, strong) NSMutableArray *info; // Array that is loaded from and saved to file

@end

@implementation GameInfo

#define GAME_INFO_FILENAME @"game_info.dat"

- (NSMutableArray *)info
{
    if (!_info) _info = [[NSMutableArray alloc] init];
    return _info;
}

- (instancetype)init
{
    self = [super init];
    
    [self setEmptyInfoArray];
    
    return self;
}

#define DEFAULT_GRID_SIZE 4

- (void)setEmptyInfoArray
{
    [self.info removeAllObjects];
    
    // First item: current grid size
    
    // TODO: save as array to enable several additional values. For example: sound state (ON/OFF)
    
    [self.info addObject:[NSNumber numberWithInteger:DEFAULT_GRID_SIZE]];
    
    // Second to fifth items: board info, blocked cells, can't finish and solution
    
    [self addEmptyBoardInfo:DEFAULT_GRID_SIZE];
}

- (void)addEmptyBoardInfo:(NSUInteger)gridSize
{
    Board *newBoard = [[Board alloc] initWithNumCols:gridSize numRows:gridSize];
    
    // First item: board info: array of cur index, score, best score, level start index
    
    NSMutableArray *boardInfo = [NSMutableArray arrayWithArray:@[[NSNumber numberWithInteger:newBoard.curIndex],
                                                                 [NSNumber numberWithInteger:newBoard.score],
                                                                 [NSNumber numberWithInteger:newBoard.score],
                                                                 [NSNumber numberWithInteger:newBoard.curIndex]]];
    
    [self.info addObject:boardInfo];
    
    // Second item: board blocked cells
    
    NSMutableArray *blocked = [[NSMutableArray alloc] init];
    
    for (NSUInteger index = 0; index < [newBoard numCells]; index++) {
        if (![newBoard cellInIndexIsFree:index]) {
            [blocked addObject:[NSNumber numberWithInteger:index]];
        }
    }
    
    [self.info addObject:blocked];
    
    // Third item: board can't finish cells
    
    NSMutableArray *cantFinish = [[NSMutableArray alloc] init];
    
    for (NSUInteger index = 0; index < [newBoard numCells]; index++) {
        if (![newBoard canFinishInIndex:index]) {
            [cantFinish addObject:[NSNumber numberWithInteger:index]];
        }
    }
    
    [self.info addObject:cantFinish];
    
    // Forth item: board current solution
    
    NSMutableArray *solution = [[NSMutableArray alloc] init];
    
    [self.info addObject:solution];
}

- (void)nullBoardInfoBlock:(NSUInteger)boardInfoIndex gridSize:(NSUInteger)gridSize
{
    // TODO: unite with addEmptyBoardInfo to avoid code duplication. For now avoid risk of currpting tested code
    
    Board *newBoard = [[Board alloc] initWithNumCols:gridSize numRows:gridSize];
    self.info[boardInfoIndex] = [NSMutableArray arrayWithArray:@[[NSNumber numberWithInteger:newBoard.curIndex],
                                                                 [NSNumber numberWithInteger:newBoard.score],
                                                                 [NSNumber numberWithInteger:newBoard.score],
                                                                 [NSNumber numberWithInteger:newBoard.curIndex]]];

    NSMutableArray *blocked = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < [newBoard numCells]; index++) {
        if (![newBoard cellInIndexIsFree:index]) {
            [blocked addObject:[NSNumber numberWithInteger:index]];
        }
    }
    self.info[boardInfoIndex + 1] = blocked;
    
    NSMutableArray *cantFinish = [[NSMutableArray alloc] init];
    for (NSUInteger index = 0; index < [newBoard numCells]; index++) {
        if (![newBoard canFinishInIndex:index]) {
            [cantFinish addObject:[NSNumber numberWithInteger:index]];
        }
    }
    self.info[boardInfoIndex + 2] = cantFinish;
    
    self.info[boardInfoIndex + 3] = [[NSMutableArray alloc] init];
}

- (NSUInteger)curGridSize
{
    // TODO: when changing self.info[0] to be an array - access to first array value
    return [self.info[0] integerValue];
}

- (NSUInteger)score
{
    NSMutableArray *boardInfo = self.info[[self firstInfoItemIndex]];
    return [boardInfo[1] integerValue];
}

- (NSUInteger)bestScore
{
    NSMutableArray *boardInfo = self.info[[self firstInfoItemIndex]];
    return [boardInfo[2] integerValue];
}

- (NSUInteger)levelStartIndex
{
    NSMutableArray *boardInfo = self.info[[self firstInfoItemIndex]];
    return [boardInfo[3] integerValue];
}

- (NSUInteger)prevLevelStartIndex
{
    NSUInteger boardInfoIndex = [self firstInfoItemIndex];
    NSMutableArray *solution = self.info[boardInfoIndex+3];
    
    if ([solution count] >= 2) {
        return [solution[[solution count] - 2] integerValue];
    }
    
    NSLog(@"Logic error - must not ask for prevLevelStartIndex if level is < 2");
    return [self levelStartIndex];
}

- (NSArray *)solution
{
    NSUInteger boardInfoIndex = [self firstInfoItemIndex];
    return self.info[boardInfoIndex+3];
}

- (BOOL)loadInfoFromFile
{
    // Read from file
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameInfoFilename = [documentsDirectory stringByAppendingPathComponent:GAME_INFO_FILENAME];
    
    self.info = [[NSMutableArray alloc] initWithContentsOfFile:gameInfoFilename];
    
    // Verify validity
    
    if (![self verifyInfo]) {
        NSLog(@"Load failed");
        [self setEmptyInfoArray];
        return NO;
    }
    
    NSLog(@"Load success, score: %lu, best score: %lu, grid: %lu, max grid: %lu",
          (unsigned long)[self score], (unsigned long)[self bestScore], (unsigned long)[self curGridSize], (unsigned long)[self maxGridSize]);
    
    return YES;
}

#define NUM_INFO_HEADERS_ITEMS 1
#define NUM_ITEMS_PER_BOARD_IN_INFO 4
#define NUM_BOARD_INFO_ITEMS 4

- (void)loadBoardFromInfo:(Board *)board
{
    NSAssert([self curGridSize] == board.numCols, @"Board must be of the current board grid size in info");
    
    NSUInteger boardInfoFirstItemIndex = [GameInfo gridSizeToFirstInfoItemIndex:board.numCols];
    
    NSAssert(boardInfoFirstItemIndex + NUM_ITEMS_PER_BOARD_IN_INFO <= [self.info count], @"Info array is too short - fatal error");
    
    NSMutableArray* boardInfo = self.info[boardInfoFirstItemIndex];
    NSUInteger curIndex = [boardInfo[0] integerValue];
    NSUInteger score = [boardInfo[1] integerValue];
    
    [board load:curIndex withScore:score withBlockedIndices:self.info[boardInfoFirstItemIndex + 1] withCantFinishIndices:self.info[boardInfoFirstItemIndex + 2]];
}

- (NSUInteger)maxGridSize
{
    return DEFAULT_GRID_SIZE + ([self.info count] - NUM_INFO_HEADERS_ITEMS - NUM_ITEMS_PER_BOARD_IN_INFO) / NUM_ITEMS_PER_BOARD_IN_INFO;
}

- (BOOL)verifyInfo
{
    NSString* logErrorName = @"Load failure: ";
    
    if (self.info == nil) {
        NSLog(@"Array is nil");
        NSString* message = @"Array is nil";
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    
    if ([self.info count] < NUM_INFO_HEADERS_ITEMS + NUM_ITEMS_PER_BOARD_IN_INFO) {
        NSLog(@"Array too small, size: %lu", (unsigned long)[self.info count]);
        if ([self.info count] == 0) {
            [Flurry logEvent:@"Load failure: empty array"];
        }
        else {
            NSString* message = [NSString stringWithFormat:@"Small array size: %lu", (unsigned long)[self.info count]];
            [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        }
        return NO;
    }
    
    if (([self.info count] - NUM_INFO_HEADERS_ITEMS) % NUM_ITEMS_PER_BOARD_IN_INFO != 0) {
        NSLog(@"Array size is invalid: %lu", (unsigned long)[self.info count]);
        NSString* message = [NSString stringWithFormat:@"Invalid array size: %lu", (unsigned long)[self.info count]];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    
    NSUInteger curGridSize = [self curGridSize];
    NSUInteger maxGridSize = [self maxGridSize];
    
    if (curGridSize > maxGridSize || maxGridSize < DEFAULT_GRID_SIZE || curGridSize < DEFAULT_GRID_SIZE) {
        NSLog(@"Grid size invalid - doesn't match info array size");
        NSString* message = [NSString stringWithFormat:@"Invalid grid size: cur: %lu, max: %lu", (unsigned long)curGridSize, (unsigned long)maxGridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    
    for (NSUInteger gridSize = DEFAULT_GRID_SIZE; gridSize <= maxGridSize; gridSize++) {
        NSUInteger boardInfoIndex = [GameInfo gridSizeToFirstInfoItemIndex:gridSize];
        if (![self verifyInfo:gridSize
                   boardInfo:self.info[boardInfoIndex]
                     blocked:self.info[boardInfoIndex+1]
                  cantFinish:self.info[boardInfoIndex+2]
                    solution:self.info[boardInfoIndex+3]]) {
            
            NSLog(@"Data invalidity for grid size: %lu, nulling board info block form index: %lu",
                  (unsigned long)gridSize, (unsigned long)boardInfoIndex);
            
            NSString* message = [NSString stringWithFormat:@"Data invalidity for grid size: %lu. Board info: %@, blocked: %@, can't finish: %@, solution: %@",
                                 (unsigned long)gridSize,
                                 self.info[boardInfoIndex], self.info[boardInfoIndex+1],
                                 self.info[boardInfoIndex+2], self.info[boardInfoIndex+3]];
            [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
            
            [self nullBoardInfoBlock:boardInfoIndex gridSize:gridSize];
        }
    }
    
    return YES;
}

- (BOOL)verifyInfo:(NSUInteger)gridSize boardInfo:(NSMutableArray *)boardInfo blocked:(NSMutableArray *)blockedIndices cantFinish:(NSMutableArray *)cantFinishIndices solution:(NSMutableArray *)solution
{
    NSUInteger curIndex = [boardInfo[0] integerValue];
    NSUInteger score = [boardInfo[1] integerValue];
    NSUInteger bestScore = [boardInfo[2] integerValue];
    NSUInteger levelStartIndex = [boardInfo[3] integerValue];
 
    NSString* logErrorName = @"Load failure: ";
    
    if (score > [Board maxScore:gridSize numRows:gridSize]) {
        NSLog(@"Score higher than maximum: %lu, grid size: %lu",
              (unsigned long)score, (unsigned long)gridSize);
        NSString* message = [NSString stringWithFormat:@"Score higher than maximum: %lu, grid size: %lu",
                             (unsigned long)score, (unsigned long)gridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    if (bestScore > [Board maxScore:gridSize numRows:gridSize]) {
        NSLog(@"Best score higher than maximum: %lu, grid size: %lu",
              (unsigned long)bestScore, (unsigned long)gridSize);
        NSString* message = [NSString stringWithFormat:@"Best score higher than maximum: %lu, grid size: %lu",
                             (unsigned long)bestScore, (unsigned long)gridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    if (score > bestScore) {
        NSLog(@"Score higher than best score: %lu, best: %lu, grid size: %lu",
              (unsigned long)score, (unsigned long)bestScore, (unsigned long)gridSize);
        NSString* message = [NSString stringWithFormat:@"Score higher than best score: %lu, best: %lu, grid size: %lu",
                             (unsigned long)score, (unsigned long)bestScore, (unsigned long)gridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    
    for (NSNumber *index in blockedIndices) {
        NSUInteger i = [index integerValue];
        if (i >= [Board numCells:gridSize numRows:gridSize]) {
            NSLog(@"Invalid blocked index out of range: %lu, grid size: %lu",
                  (unsigned long)i, (unsigned long)gridSize);
            NSString* message = [NSString stringWithFormat:@"Invalid blocked index out of range: %lu, grid size: %lu",
                                 (unsigned long)i, (unsigned long)gridSize];
            [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
            return NO;
        }
    }
    if (![blockedIndices containsObject:[NSNumber numberWithInteger:curIndex]]) {
        NSLog(@"Cur index is not blocked but must be: %lu, grid size: %lu",
              (unsigned long)curIndex, (unsigned long)gridSize);
        NSString* message = [NSString stringWithFormat:@"Cur index is not blocked but must be: %lu, grid size: %lu",
                             (unsigned long)curIndex, (unsigned long)gridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    for (NSNumber *index in cantFinishIndices) {
        NSUInteger i = [index integerValue];
        if (i >= [Board numCells:gridSize numRows:gridSize]) {
            NSLog(@"Invalid can't finish index out of range: %lu, grid size: %lu",
                  (unsigned long)i, (unsigned long)gridSize);
            NSString* message = [NSString stringWithFormat:@"Invalid can't finish index out of range: %lu, grid size: %lu",
                                 (unsigned long)i, (unsigned long)gridSize];
            [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
            return NO;
        }
    }
    
    NSUInteger level = score / [Board maxLevelScore:gridSize numRows:gridSize];
    
    if (![cantFinishIndices containsObject:[NSNumber numberWithInteger:levelStartIndex]] && level > 0) {
        NSLog(@"Can't finish indices don't contain level start index. Level: %lu, level start index: %lu, grid size: %lu",
              (unsigned long)level, (unsigned long)levelStartIndex, (unsigned long)gridSize);
        NSString* message = [NSString stringWithFormat:@"Can't finish indices don't contain level start index. Level: %lu, level start index: %lu, grid size: %lu",
                             (unsigned long)level, (unsigned long)levelStartIndex, (unsigned long)gridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    if ([[solution lastObject] integerValue] != levelStartIndex && level > 0) {
        NSLog(@"Solution last object doesn't match level start index. Solution: %@, level: %lu, level start index: %lu, grid size: %lu", solution, (unsigned long)level, (unsigned long)levelStartIndex, (unsigned long)gridSize);
        NSString* message = [NSString stringWithFormat:@"Solution last object doesn't match level start index. Solution: %@, level: %lu, level start index: %lu, grid size: %lu", solution, (unsigned long)level, (unsigned long)levelStartIndex, (unsigned long)gridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    if (level != [cantFinishIndices count]) {
        NSLog(@"Score doesn't match count of can't finish indices array, score: %lu, level: %lu, cant finish count: %lu, grid size: %lu", (unsigned long)score, (unsigned long)level, (unsigned long)[cantFinishIndices count], (unsigned long)gridSize);
        NSString* message = [NSString stringWithFormat:@"Score doesn't match count of can't finish indices array, score: %lu, level: %lu, cant finish count: %lu, grid size: %lu", (unsigned long)score, (unsigned long)level, (unsigned long)[cantFinishIndices count], (unsigned long)gridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    if ([solution count] != [cantFinishIndices count]) {
        NSLog(@"Solution count doesn't match level / can't finish indices count. Solution: %@, count: %lu, can't finish count: %lu, grid size: %lu", solution, (unsigned long)[solution count], (unsigned long)[cantFinishIndices count], (unsigned long)gridSize);
        NSString* message = [NSString stringWithFormat:@"Solution count doesn't match level / can't finish indices count. Solution: %@, count: %lu, can't finish count: %lu, grid size: %lu", solution, (unsigned long)[solution count], (unsigned long)[cantFinishIndices count], (unsigned long)gridSize];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    for (NSNumber *index in solution) {
        if (![cantFinishIndices containsObject:index]) {
            NSLog(@"Can't finish indices array doesn't include a solution value: %lu, level: %lu, grid size: %lu",
                  (unsigned long)[index integerValue], (unsigned long)level, (unsigned long)gridSize);
            NSString* message = [NSString stringWithFormat:@"Can't finish indices array doesn't include a solution value: %lu, level: %lu, grid size: %lu",
                                 (unsigned long)[index integerValue], (unsigned long)level, (unsigned long)gridSize];
            [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
            return NO;
        }
    }
    
    NSUInteger movesInLevel = score % [Board maxLevelScore:gridSize numRows:gridSize];
    
    if (movesInLevel != [blockedIndices count] - 1) {
        NSLog(@"Score doesn't match moves in level: %lu, score: %lu, grid size: %lu, num blocked cells: %lu",
              (unsigned long)movesInLevel, (unsigned long)score, (unsigned long)gridSize, (unsigned long)([blockedIndices count] - 1));
        NSString* message = [NSString stringWithFormat:@"Score doesn't match moves in level: %lu, score: %lu, grid size: %lu, num blocked cells: %lu",
                             (unsigned long)movesInLevel, (unsigned long)score, (unsigned long)gridSize, (unsigned long)([blockedIndices count] - 1)];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
        return NO;
    }
    
    return YES;
}

- (NSUInteger)firstInfoItemIndex
{
    return [GameInfo gridSizeToFirstInfoItemIndex:[self curGridSize]];
}

+ (NSUInteger)gridSizeToFirstInfoItemIndex:(NSUInteger)gridSize
{
    return (gridSize - DEFAULT_GRID_SIZE) * NUM_ITEMS_PER_BOARD_IN_INFO + NUM_INFO_HEADERS_ITEMS; // (gridSize - 4) * 4 + 1;
}

- (void)updateInfoFromBoard:(Board *)board
{
    NSAssert([self curGridSize] == board.numCols, @"Current grid size %lu must match board grid size %lu",
             (unsigned long)[self curGridSize], (unsigned long)board.numCols);
    
    NSUInteger boardInfoIndex = [self firstInfoItemIndex];
    NSMutableArray *boardInfo = self.info[boardInfoIndex];
    
    boardInfo[0] = [NSNumber numberWithInteger:board.curIndex];
    boardInfo[1] = [NSNumber numberWithInteger:board.score];
    boardInfo[2] = [NSNumber numberWithInteger:MAX(board.score, [boardInfo[2] integerValue])];
    
    NSMutableArray *blocked = self.info[boardInfoIndex+1];
    [blocked removeAllObjects];
    for (NSUInteger index = 0; index < [board numCells]; index++) {
        if (![board cellInIndexIsFree:index]) {
            [blocked addObject:[NSNumber numberWithInteger:index]];
        }
    }
    
    NSMutableArray *cantFinish = self.info[boardInfoIndex+2];
    [cantFinish removeAllObjects];
    for (NSUInteger index = 0; index < [board numCells]; index++) {
        if (![board canFinishInIndex:index]) {
            [cantFinish addObject:[NSNumber numberWithInteger:index]];
        }
    }
}

- (void)resetLevel:(Board *)board
{
    [board resetLevel:[self levelStartIndex]];
    
    [self updateInfoFromBoard:board];
    
    [self save];
}

- (void)restart:(Board *)board
{
    NSUInteger boardInfoIndex = [self firstInfoItemIndex];
    NSMutableArray *boardInfo = self.info[boardInfoIndex];
    NSMutableArray *solution = self.info[boardInfoIndex+3];
    
    [board reset];
    
    [self updateInfoFromBoard:board];
    
    boardInfo[3] = boardInfo[0];
    
    [solution removeAllObjects];
    
    [self save];
}

- (void)advance:(Board *)board
{
    [board advance];
    
    NSUInteger boardInfoIndex = [self firstInfoItemIndex];
    NSMutableArray *boardInfo = self.info[boardInfoIndex];
    NSMutableArray *solution = self.info[boardInfoIndex+3];

    boardInfo[3] = [NSNumber numberWithInteger:board.curIndex];
    
    [solution addObject:[NSNumber numberWithInteger:board.curIndex]];
    
    [self updateInfoFromBoard:board];
}

- (void)goBack:(Board *)board
{
    [board goBack:[self levelStartIndex]];
    
    NSUInteger boardInfoIndex = [self firstInfoItemIndex];
    NSMutableArray *boardInfo = self.info[boardInfoIndex];
    NSMutableArray *solution = self.info[boardInfoIndex+3];

    [solution removeLastObject];
    
    boardInfo[3] = [solution lastObject];
    
    [self updateInfoFromBoard:board];
}

- (void)addEmptyBoardInfo
{
    NSAssert([self curGridSize] == [self maxGridSize], @"Cannot add a new board info if not playing in the max grid size");
    
    [self addEmptyBoardInfo:[self maxGridSize]+1];
}

- (void)toggleGridSize
{
    NSAssert([self maxGridSize] > DEFAULT_GRID_SIZE, @"Must have something to toggle with");
    
    NSUInteger curGridSize = [self curGridSize];
    NSUInteger nextGridSize = curGridSize + 1;
    if (curGridSize == [self maxGridSize]) {
        nextGridSize = DEFAULT_GRID_SIZE;
    }
    
    // TODO: when changing self.info[0] to be an array - set the first array value
    self.info[0] = [NSNumber numberWithInteger:nextGridSize];
}

- (void)save
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameInfoFilename = [documentsDirectory stringByAppendingPathComponent:GAME_INFO_FILENAME];
    
    [self.info writeToFile:gameInfoFilename atomically:YES];
    
    NSLog(@"Save success, score: %lu, grid: %lu", (unsigned long)[self score], (unsigned long)[self curGridSize]);
}

- (void)deleteGameInfoFile
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameInfoFilename = [documentsDirectory stringByAppendingPathComponent:GAME_INFO_FILENAME];
    NSError *error = nil;
    [manager removeItemAtPath:gameInfoFilename error:&error];
}

@end
