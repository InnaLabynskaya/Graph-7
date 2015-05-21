//
//  Node.h
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Node : NSObject

@property (strong, nonatomic, readonly) NSString *url;
@property (strong, nonatomic, readonly) NSMutableSet *edges;
@property (nonatomic) BOOL wasParsed;
@property (nonatomic) NSUInteger countURLs;

- (instancetype)initWithUrl:(NSString*)url;

- (void)addEdgeToNode:(Node *)node;
- (void)removeEdgeToNode:(Node *)node;
- (void)removeAllEdges;

@end
