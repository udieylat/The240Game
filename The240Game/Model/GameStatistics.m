//
//  GameStatistics.m
//  240
//
//  Created by Yuval on 9/23/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import "Flurry.h"

#import "GameStatistics.h"

@interface GameStatistics()

@property (nonatomic) NSUInteger totalSteps;
@property (nonatomic) NSUInteger totalRetries;
@property (nonatomic) NSUInteger totalGoBacks;
@property (nonatomic) NSUInteger totalRestarts;
@property (nonatomic) NSUInteger totalEndCellsHighlights;
@property (nonatomic) NSUInteger totalDeadEnds;

@property (nonatomic) NSUInteger retriesForLevel;

@end

@implementation GameStatistics

#define GAME_STATS_FILENAME @"game_stats.dat"

- (NSUInteger)totalSteps
{
    if (!_totalSteps) _totalSteps = 0;
    return _totalSteps;
}

- (NSUInteger)totalRetries
{
    if (!_totalRetries) _totalRetries = 0;
    return _totalRetries;
}

- (NSUInteger)totalGoBacks
{
    if (!_totalGoBacks) _totalGoBacks = 0;
    return _totalGoBacks;
}

- (NSUInteger)totalRestarts
{
    if (!_totalRestarts) _totalRestarts = 0;
    return _totalRestarts;
}

- (NSUInteger)totalEndCellsHighlights
{
    if (!_totalEndCellsHighlights) _totalEndCellsHighlights = 0;
    return _totalEndCellsHighlights;
}

- (NSUInteger)totalDeadEnds
{
    if (!_totalDeadEnds) _totalDeadEnds = 0;
    return _totalDeadEnds;
}

- (NSUInteger)retriesForLevel
{
    if (!_retriesForLevel) _retriesForLevel = 0;
    return _retriesForLevel;
}

- (void)step
{
    self.totalSteps++;
}

+ (NSString *)numToStr:(NSUInteger)num
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)num];
}

- (void)advance:(NSUInteger)level gridSize:(NSUInteger)gridSize
{
    [Flurry logEvent:@"Level advance" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      [GameStatistics numToStr:self.retriesForLevel], @"Retries for level",
                                                      [GameStatistics numToStr:level], @"Level",
                                                      [GameStatistics numToStr:gridSize], @"Grid Size",
                                                      [GameStatistics numToStr:self.totalEndCellsHighlights], @"Total highlight end-cells",
                                                      [GameStatistics numToStr:self.totalDeadEnds], @"Total dead ends",
                                                      nil]];
    
    self.retriesForLevel = 0;
}

- (void)highlightEndCells:(NSUInteger)level gridSize:(NSUInteger)gridSize
{
    [Flurry logEvent:@"Highlight End-cells" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            [GameStatistics numToStr:level], @"Level",
                                                            [GameStatistics numToStr:gridSize], @"Grid Size",
                                                            nil]];
    
    self.totalEndCellsHighlights++;
}

- (void)retry:(NSUInteger)level gridSize:(NSUInteger)gridSize
{
    [Flurry logEvent:@"Retry" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                              [GameStatistics numToStr:self.retriesForLevel], @"Retries for level",
                                              [GameStatistics numToStr:level], @"Level",
                                              [GameStatistics numToStr:gridSize], @"Grid Size",
                                              [GameStatistics numToStr:self.totalEndCellsHighlights], @"Total highlight end-cells",
                                              [GameStatistics numToStr:self.totalDeadEnds], @"Total dead ends until now",
                                              nil]];
    self.totalRetries++;
    self.retriesForLevel++;
}

- (void)goBack:(NSUInteger)fromLevel gridSize:(NSUInteger)gridSize
{
    [Flurry logEvent:@"Go back" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [GameStatistics numToStr:self.retriesForLevel], @"Retries for level",
                                                [GameStatistics numToStr:fromLevel], @"From level",
                                                [GameStatistics numToStr:gridSize], @"Grid Size",
                                                [GameStatistics numToStr:self.totalEndCellsHighlights], @"Total highlight end-cells",
                                                [GameStatistics numToStr:self.totalDeadEnds], @"Total dead ends",
                                                nil]];
    self.totalGoBacks++;
    self.retriesForLevel = 0;
}

- (void)restart:(NSUInteger)level gridSize:(NSUInteger)gridSize
{
    [Flurry logEvent:@"Restart" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                [GameStatistics numToStr:self.retriesForLevel], @"Retries for level",
                                                [GameStatistics numToStr:level], @"Level",
                                                [GameStatistics numToStr:gridSize], @"Grid Size",
                                                [GameStatistics numToStr:self.totalEndCellsHighlights], @"Total highlight end-cells",
                                                [GameStatistics numToStr:self.totalDeadEnds], @"Total dead ends",
                                                nil]];
    self.totalRestarts++;
    self.retriesForLevel = 0;
}

- (void)impossibleGame:(NSUInteger)level gridSize:(NSUInteger)gridSize
{
    [Flurry logEvent:@"Reached Impossible Game" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [GameStatistics numToStr:level], @"Level",
                                                                [GameStatistics numToStr:gridSize], @"Grid Size",
                                                                [GameStatistics numToStr:self.totalEndCellsHighlights], @"Total highlight end-cells",
                                                                [GameStatistics numToStr:self.totalDeadEnds], @"Total dead ends until now",
                                                                nil]];

    self.totalDeadEnds++;
}

- (void)reset
{
    self.totalSteps = 0;
    self.totalRetries = 0;
    self.totalGoBacks = 0;
    self.totalRestarts = 0;
    self.retriesForLevel = 0;
    self.totalDeadEnds = 0;
    self.totalEndCellsHighlights = 0;
    
    [self save];
}

+ (NSString *)gridSizeToStr:(NSUInteger)gridSize
{
    return [NSString stringWithFormat:@"%lux%lu", (unsigned long)gridSize, (unsigned long)gridSize];
}

- (void)gameCompleted:(NSUInteger)gridSize solution:(NSArray *)solution gameCompletionBoardIndex:(NSUInteger)gameCompletionBoardIndex
{
    NSMutableArray *solutionStringsArray = [[NSMutableArray alloc] init];
    for (NSNumber *index in solution) {
        [solutionStringsArray addObject:[GameStatistics numToStr:[index integerValue]]];
    }
    [solutionStringsArray addObject:[GameStatistics numToStr:gameCompletionBoardIndex]];
    
    NSLog(@"Game completed with solution: %@", [solutionStringsArray componentsJoinedByString:@" "]);
    
    NSString *solutionString = [solutionStringsArray componentsJoinedByString:@" "];
    
    NSMutableDictionary* logsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [GameStatistics gridSizeToStr:gridSize], @"Game completed",
                                     [GameStatistics numToStr:self.totalSteps], @"Total number of steps",
                                     [GameStatistics numToStr:self.totalRetries], @"Total number of retries",
                                     [GameStatistics numToStr:self.totalGoBacks], @"Total number of go backs",
                                     [GameStatistics numToStr:self.totalRestarts], @"Total number of restarts",
                                     [GameStatistics numToStr:self.totalEndCellsHighlights], @"Total highlight end-cells",
                                     [GameStatistics numToStr:self.totalDeadEnds], @"Total dead ends",
                                     nil];
    
    [logsDict setObject:solutionString forKey:@"Solution"];

    [Flurry logEvent:@"Game completed" withParameters:logsDict];
    
    [self reset];
}

- (void)toggleGridSize:(NSUInteger)toGridSize
{
    [Flurry logEvent:@"Toggle grid size" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [GameStatistics gridSizeToStr:toGridSize], @"Toggle to grid size",
                                                         nil]];
 
    // TODO: bug here - messes up the game statistics because the statistics are being reset whereas the other grid game starts from a saved position.
    
    [self reset];    
}

- (void)save
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameStatsFilename = [documentsDirectory stringByAppendingPathComponent:GAME_STATS_FILENAME];
  
    NSArray *statsArray = [self generateStatsArrayToFile];
    
    [statsArray writeToFile:gameStatsFilename atomically:YES];
    
//    NSLog(@"Saved stats array: %@", statsArray);
}

- (void)load
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameStatsFilename = [documentsDirectory stringByAppendingPathComponent:GAME_STATS_FILENAME];
    
    NSArray *statsArrayFromFile = [[NSArray alloc] initWithContentsOfFile:gameStatsFilename];

    if (statsArrayFromFile != nil && [statsArrayFromFile count] > 0) {
        [self setStatsFromArray:statsArrayFromFile];
//        NSLog(@"Stats file load success: %@", statsArrayFromFile);
        NSLog(@"Stats file load success");
    }
    else {
        NSLog(@"Stats file load failed - empty or nil array"); // All stats are zero - good behavior
    }
}

- (NSArray *)generateStatsArrayToFile
{
    // TODO: separate stats for different grid sizes
    
    NSMutableArray *statsArray = [[NSMutableArray alloc] init];
    
    [statsArray addObject:[NSNumber numberWithInteger:self.totalSteps]];
    [statsArray addObject:[NSNumber numberWithInteger:self.totalRetries]];
    [statsArray addObject:[NSNumber numberWithInteger:self.totalGoBacks]];
    [statsArray addObject:[NSNumber numberWithInteger:self.totalRestarts]];
    [statsArray addObject:[NSNumber numberWithInteger:self.totalEndCellsHighlights]];
    [statsArray addObject:[NSNumber numberWithInteger:self.totalDeadEnds]];
    [statsArray addObject:[NSNumber numberWithInteger:self.retriesForLevel]];
    
    for (int i = 0; i<30; i++) {
        [statsArray addObject:[NSNumber numberWithInteger:0]]; // To avoid out of range events
    }
    
    return statsArray;
}

- (void)setStatsFromArray:(NSArray *)statsArray
{
    int i = 0;
    self.totalSteps = [statsArray[i] integerValue]; i++;
    self.totalRetries = [statsArray[i] integerValue]; i++;
    self.totalGoBacks = [statsArray[i] integerValue]; i++;
    self.totalRestarts = [statsArray[i] integerValue]; i++;
    self.totalEndCellsHighlights = [statsArray[i] integerValue]; i++;
    self.totalDeadEnds = [statsArray[i] integerValue]; i++;
    self.retriesForLevel = [statsArray[i] integerValue]; i++;
}

@end
