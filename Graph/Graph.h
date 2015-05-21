//
//  Graph.h
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface Graph : NSObject

@property (nonatomic, strong, readonly) NSString *rootUrl;
@property (nonatomic, strong, readonly) NSMutableDictionary *nodes;
@property (nonatomic, strong, readonly) Node *rootNode;

- (instancetype)initGraphWithRootLink:(NSString*)rootUrl;
- (void)addNode:(Node *)node;
- (Node*)nodeForUrl:(NSString*)url;
- (void)buildSiteMap;
- (void)buildSiteMapWithMaxIterations:(NSUInteger)maxIter;
- (void)breadthFirstSearchFromNode:(Node*)node maxIterations:(NSUInteger)maxIterations;

- (void)buildNextGeneration;
- (NSArray*)firstGenerationFromNode:(Node*)node;

@end
