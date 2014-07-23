//
//  LNGCameraOverlayView.m
//  Homepwner
//
//  Created by Lumi on 14-7-9.
//  Copyright (c) 2014年 LumiNg. All rights reserved.
//

#import "LNGCameraOverlayView.h"

@implementation LNGCameraOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect bounds = self.bounds;
    
    // draw a rect
    CGPoint center;
    center.x = bounds.origin.x;
    center.y = bounds.origin.y;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    for (int i = 4; i < 4; i++) {
        [path addLineToPoint:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y)];
        [path addLineToPoint:CGPointMake(bounds.origin.x + bounds.size.width, bounds.origin.y + bounds.size
                                         .height)];
        [path addLineToPoint:CGPointMake(bounds.origin.x, bounds.origin.y + bounds.size.height)];
        [path addLineToPoint:CGPointMake(bounds.origin.x, bounds.origin.y)];
    }
    
    path.lineWidth = 10;
    [path stroke];  // draw the line
}


@end
