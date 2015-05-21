//
//  NodeView.m
//  Graph
//
//  Created by User on 5/14/15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "NodeView.h"

@interface NodeView()

@property (nonatomic, weak) UILabel *urlLabel;
@property (nonatomic, strong) LineView *neighboursLineView;

@end

@implementation NodeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}

- (void)initializeSubviews
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.urlLabel = label;
    [self.urlLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.urlLabel];
}

- (void)setNode:(Node *)node
{
    _node = node;
    self.urlLabel.text = [@(node.countURLs) stringValue];//node.url;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetRGBFillColor(context, 255, 255, 255, 1);
    CGContextFillRect(context, rect);
    if (self.node.countURLs < 5) {
        CGContextSetRGBFillColor(context, (255.0), (255.0), 0, 1);
    } else if (self.node.countURLs >= 5 && self.node.countURLs < 10) {
        CGContextSetRGBFillColor(context, 255,0, 0, 1);
    } else if (self.node.countURLs >= 10 && self.node.countURLs < 20) {
        CGContextSetRGBFillColor(context, 0, 255, 0, 1);
    } else if (self.node.countURLs >= 20 && self.node.countURLs < 30){
        CGContextSetRGBFillColor(context, 0, 0, 255, 1);
    } else {
        CGContextSetRGBFillColor(context, 255, (128/255.0), 0, 1);
    }
    
    CGContextFillEllipseInRect(context, rect);
}

@end
