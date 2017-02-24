//
//  BoardView.m
//  The240Game
//
//  Created by Yuval on 8/13/14.
//  Copyright (c) 2014 Udi. All rights reserved.
//

#import "BoardView.h"

@implementation BoardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setup
{
    self.backgroundColor = nil;//[UIColor blueColor];
    self.opaque = NO;
    self.contentMode = UIViewContentModeRedraw;
    
//    UIBezierPath* bp = [UIBezierPath bezierPathWithRect:self.bounds];
//    [[UIColor colorWithRed:16/255.0 green:78/255.0 blue:139/255.0 alpha:1.0] setStroke];
//    [bp stroke];
}

- (void)awakeFromNib
{
    [self setup];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat size = MAX(self.bounds.size.width, self.bounds.size.height);
    CGRect square = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, size, size);
    UIBezierPath* bp = [UIBezierPath bezierPathWithRect:square];
    
    [[UIColor blackColor] setStroke];
    [bp stroke];
}
*/

@end
