//
//  Node.m
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "Node.h"

@interface Node ()

@property (strong, nonatomic, readwrite) NSString *url;
@property (strong, nonatomic, readwrite) NSMutableSet *edges;

@end

@implementation Node

- (instancetype)initWithUrl:(NSString*)url
{
    self = [super init];
    if (self) {
        self.wasParsed = NO;
        self.url = url;
        self.edges = [NSMutableSet set];
        self.countURLs = 1;
    }
    return self;
}

- (instancetype)init
{
    return [self initWithUrl:nil];
}

- (void)addEdgeToNode:(Node *)node
{
    [self.edges addObject:node.url];
    node.countURLs++;
}

- (void)removeEdgeToNode:(Node *)node
{
    [self.edges removeObject:node.url];
}

- (void)removeAllEdges
{
    [self.edges removeAllObjects];
}

@end
