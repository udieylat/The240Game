//
//  Solver.h
//  240
//
//  Created by Yuval on 9/24/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Solver : NSObject

- (NSArray *)getEndCells:(NSUInteger)gridSize startIndex:(NSUInteger)startIndex;

@end
