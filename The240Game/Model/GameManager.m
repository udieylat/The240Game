//
//  GameManager.m
//  240
//
//  Created by Yuval on 10/19/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import "GameManager.h"

@implementation GameManager

#define GAME_MANAGER_INFO_FILENAME @"game_manager_info.dat"

- (BOOL)singlesMode
{
    if (!_singlesMode) _singlesMode = NO;
    return _singlesMode;
}

- (BOOL)soundIsOn
{
    if (!_soundIsOn) _soundIsOn = NO;
    return _soundIsOn;
}

- (void)save
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameInfoFilename = [documentsDirectory stringByAppendingPathComponent:GAME_MANAGER_INFO_FILENAME];
    
    NSArray *arrToSave = @[[NSNumber numberWithBool:self.singlesMode], [NSNumber numberWithBool:self.soundIsOn]];
    
    [arrToSave writeToFile:gameInfoFilename atomically:YES];
    
    NSLog(@"Game manager file save success. Singles mode: %@, sound: %@", self.singlesMode ? @"ON" : @"OFF", self.soundIsOn ? @"ON" : @"OFF");
}

- (void)load
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gameInfoFilename = [documentsDirectory stringByAppendingPathComponent:GAME_MANAGER_INFO_FILENAME];
    
    NSArray *arrFromFile = [[NSArray alloc] initWithContentsOfFile:gameInfoFilename];
    
    if (arrFromFile == nil || [arrFromFile count] == 0) {
        NSLog(@"Game manager file load failed - empty or nil array");
        [self loadFailure];
    }
    else if ([arrFromFile count] == 2) {
        self.singlesMode = [arrFromFile[0] boolValue];
        self.soundIsOn = [arrFromFile[1] boolValue];
        NSLog(@"Game manager file load success. Singles mode: %@, sound: %@", self.singlesMode ? @"ON" : @"OFF", self.soundIsOn ? @"ON" : @"OFF");
    }
    else {
        NSLog(@"Game manager file load error - invalid array size: %@", arrFromFile);
        [self loadFailure];
    }
}

- (void)loadFailure
{
    self.singlesMode = NO;
    self.soundIsOn = YES;
    [self save];
}

@end
