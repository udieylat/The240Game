//
//  SinglesModeManager.m
//  240
//
//  Created by Yuval on 10/17/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import "Flurry.h"

#import "SinglesModeManager.h"

@interface SinglesModeManager()

@property (nonatomic, readwrite) NSUInteger curLevel;
@property (nonatomic, readwrite) NSUInteger maxLevel;

@property (nonatomic) NSUInteger numRetries;
@property (nonatomic) BOOL with5x5;

@end

@implementation SinglesModeManager

- (NSUInteger)curLevel
{
    if (!_curLevel) _curLevel = 0;
    return _curLevel;
}

- (NSUInteger)maxLevel
{
    if (!_maxLevel) _maxLevel = 0;
    return _maxLevel;
}

- (NSUInteger)numRetries
{
    if (!_numRetries) _numRetries = 0;
    return _numRetries;
}

- (BOOL)with5x5
{
    if (!_with5x5) _with5x5 = NO;
    return _with5x5;
}

+ (NSString *)numToStr:(NSUInteger)num
{
    return [NSString stringWithFormat:@"%lu", (unsigned long)num];
}

- (BOOL)advanceCheckGameCompleted
{
    BOOL gameCompleted = NO;
    
    if (self.curLevel == self.maxLevel) {
        if (self.maxLevel+1 == [self numLevels]) {
            self.with5x5 = YES;
            gameCompleted = YES;
        }
        self.maxLevel++;
    }
    
    if (self.maxLevel == [self numLevels]) {
        NSLog(@"Game is fully completed - no more levels"); // Need to beware not to access the level due to index invalid range
        gameCompleted = YES; // Was not set if we were already in grid 5x5
    }

    // It's OK to first advance the level counter and only then to log (OK to count levels from 1 to 72, not from 0 to 71).
    self.curLevel++;

    [Flurry logEvent:@"Singles level advance" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                [SinglesModeManager numToStr:self.curLevel], @"Level",
                                                                [SinglesModeManager numToStr:self.numRetries], @"Number of retries",
                                                                nil]];
    
    self.numRetries = 0;
    
    [self save];
    
    return gameCompleted;
}

- (void)retry
{
    self.numRetries++;
    [self save];
}

- (NSArray *)allLevels // const
{
    NSMutableArray *allLevels = [NSMutableArray arrayWithArray:[self allLevels4x4]];
    
    if (self.with5x5) {
        [allLevels addObjectsFromArray:[self allLevels5x5]];
    }
    
    return allLevels;
}

- (NSArray *)allLevels4x4 // const
{
    return @[ @[@12, @10],
              @[@12, @11],
              @[@12, @14],
              @[@12, @13],
              @[@12, @6], // 5 from the corner
              @[@13, @5],
              @[@13, @11], // 2 from the side
              @[@9, @10],
              @[@9, @6],
              @[@9, @15], // 3 from the middle
              @[@13, @6],
              @[@13, @9],
              @[@13, @10],
              @[@13, @4], // 4 from the side
              @[@12, @9],
              @[@12, @15]]; // 2 from the corner
}

- (NSArray *)allLevels5x5 // const
{
    return @[ @[@20, @12], @[@20, @8], @[@20, @13], @[@20, @18], @[@20, @17], // 5 corner
              @[@21, @12], @[@21, @13], @[@21, @8], @[@21, @6], @[@21, @11], @[@21, @0], @[@21, @18], @[@21, @17], // 8 side side
              @[@22, @12], @[@22, @7], @[@22, @17], @[@22, @8], @[@22, @4], @[@22, @13], // 6 side center
              @[@16, @13], @[@16, @19], @[@16, @18], @[@16, @12], @[@16, @8], // 5 center corner
              @[@17, @7], @[@17, @8], @[@17, @12], @[@17, @19], // 4 center side
              
              @[@20, @16], @[@21, @16], @[@22, @18], @[@16, @17], @[@17, @13], @[@17, @18], // difficult

              @[@20, @23], @[@20, @22], @[@20, @9], @[@20, @14], @[@20, @19],
              @[@21, @7], @[@21, @5], @[@21, @2], @[@21, @1], @[@21, @15], @[@21, @23], @[@21, @19],
              @[@22, @3], @[@22, @9], @[@22, @19], @[@22, @24],
              @[@16, @23], @[@16, @24],
              @[@17, @3], @[@17, @4], @[@17, @14],
              
              @[@12, @13] // center
              ];

    // corner (20): 11/11
    // side side (21): 16/16
    // side center (22): 11/11
    // center corner (16): 8/8
    // center side (17): 9/9
    // center (12): 1/1
    
    // TODO: option to buy guided solutions??
}

- (BOOL)levelGridIs4x4
{
    return self.curLevel < [[self allLevels4x4] count];
}

- (NSUInteger)numLevels // const
{
    return [[self allLevels] count];
}

- (NSUInteger)numLevels4x4 // const
{
    return [[self allLevels4x4] count];
}

- (NSArray *)getLevel // const
{
    NSAssert(self.curLevel < [self numLevels], @"Cur level is out of all levels range");
    return [self allLevels][self.curLevel];
}

- (NSUInteger)getLevelStartIndex // const
{
    return [[self getLevel][0] integerValue];
}

- (NSUInteger)getLevelFinishIndex // const
{
    return [[self getLevel][1] integerValue];
}

- (void)nextLevel
{
    if (self.curLevel == self.maxLevel) {
        return;
    }
    self.curLevel++;
    
    [self save];
}

- (void)prevLevel
{
    if (self.curLevel == 0) {
        return;
    }
    self.curLevel--;
    
    [self save];
}

- (void)lastLevel
{
    self.curLevel = self.maxLevel;
    [self save];
}

- (void)firstLevel
{
    self.curLevel = 0;
    [self save];
}

#define SINGLES_GAME_INFO_FILENAME @"singles_game_info.dat"

- (void)save
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameInfoFilename = [documentsDirectory stringByAppendingPathComponent:SINGLES_GAME_INFO_FILENAME];
    
    NSArray *singlesArrToSave = @[[NSNumber numberWithInteger:self.curLevel],
                                  [NSNumber numberWithInteger:self.maxLevel],
                                  [NSNumber numberWithInteger:self.numRetries]];
    
    [singlesArrToSave writeToFile:gameInfoFilename atomically:YES];
    
    NSLog(@"Singles file save success. Cur level: %lu, max level: %lu, num retries: %lu",
          (unsigned long)self.curLevel, (unsigned long)self.maxLevel, (unsigned long)self.numRetries);
}

- (void)load
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameInfoFilename = [documentsDirectory stringByAppendingPathComponent:SINGLES_GAME_INFO_FILENAME];
    
    NSArray *singlesArrayFromFile = [[NSArray alloc] initWithContentsOfFile:gameInfoFilename];
    
    NSString *logErrorName = @"Singles file load failure: ";
    
    if (singlesArrayFromFile == nil) {
        NSLog(@"Singles file load failed - array is nil");
        NSString* message = @"Array is nil";
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
    }
    else if ([singlesArrayFromFile count] == 0) {
        NSLog(@"Singles file load failed - empty array"); // Singles data is zero - OK
        [Flurry logEvent:@"Singles file load failure: empty array"];
    }
    else if ([singlesArrayFromFile count] == 3) {
        
        self.curLevel = [singlesArrayFromFile[0] integerValue];
        self.maxLevel = [singlesArrayFromFile[1] integerValue];
        self.numRetries = [singlesArrayFromFile[2] integerValue];
        
        if (self.maxLevel >= [self numLevels]) {
            self.with5x5 = YES;
            NSLog(@"Singles mode manager loaded with 5x5 grid set ON");
            if (self.maxLevel >= [self numLevels]) {
                // TODO: fix this behavior if game is completed (maxLevel == numLevels)
                NSLog(@"File loading error - max level is larger/equal than all levels count. Max level: %lu, levels count: %lu",
                      (unsigned long)self.maxLevel, (unsigned long)[self numLevels]);
                self.maxLevel = [self numLevels]-1;
            }
        }
        
        if (self.curLevel > self.maxLevel) {
            NSLog(@"File loading error - cur level is larger than max level. Cur level: %lu, max level: %lu", (unsigned long)self.curLevel, (unsigned long)self.maxLevel);
            self.curLevel = self.maxLevel;
        }
        
        NSLog(@"Singles file load success. Cur level: %lu, max level: %lu, num retries: %lu",
              (unsigned long)self.curLevel, (unsigned long)self.maxLevel, (unsigned long)self.numRetries);
    }
    else {
        NSLog(@"Singles file load error - invalid array size: %@", singlesArrayFromFile);
        NSString* message = [NSString stringWithFormat:@"Invalid array size: %@", singlesArrayFromFile];
        [Flurry logError:[logErrorName stringByAppendingString:message] message:message error:nil];
    }
}

- (void)hack
{
    NSLog(@"HACK!");
    self.maxLevel = 0;
    self.curLevel = 0;
    self.with5x5 = NO;
    [self save];
}

@end
