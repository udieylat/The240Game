//
//  GameManager.h
//  240
//
//  Created by Yuval on 10/19/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameManager : NSObject

@property (nonatomic) BOOL singlesMode;
@property (nonatomic) BOOL soundIsOn;

- (void)save;
- (void)load;

@end
