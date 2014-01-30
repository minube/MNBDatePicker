//
//  MNBTriangleView.m
//  MNDatePicker
//
//  Created by Ruben on 28/01/14.
//  Copyright (c) 2014 minube. All rights reserved.
//

#import "MNBTriangleView.h"

@interface MNBTriangleView ()
@property (nonatomic, strong) UIColor *triangleColor;
@end

@implementation MNBTriangleView

- (id)initWithFrame:(CGRect)frame color:(UIColor *)triangleColor
{
    self = [super initWithFrame:frame];
    if (self) {
        _triangleColor = triangleColor;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame color:[UIColor redColor]];
    if (self) {
    
    }
    return self;
}

- (id)init
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint   (ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect) - 2.0, CGRectGetMidY(rect));  // mid right
    CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));  // bottom left
    CGContextClosePath(ctx);
    
    const CGFloat * components = CGColorGetComponents(self.triangleColor.CGColor);
    CGFloat red     = components[0];
    CGFloat green = components[1];
    CGFloat blue   = components[2];
    CGFloat alpha = components[3];
    
    CGContextSetRGBFillColor(ctx, red, green, blue, alpha);
    
    
    UIColor * shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 2), 3.0, shadowColor.CGColor);
    CGContextFillPath(ctx);
}

@end
