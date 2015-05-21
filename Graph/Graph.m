//
//  Graph.m
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "Graph.h"
#import "TFHpple.h"

@interface Graph()

@property (strong, nonatomic, readwrite) NSMutableDictionary *nodes;
@property (nonatomic, strong, readwrite) NSString *rootUrl;
@property (nonatomic, strong, readwrite) Node *rootNode;

@end

@implementation Graph

- (instancetype)initGraphWithRootLink:(NSString*)rootUrl;
{
    self = [super init];
    if (self) {
        self.nodes = [NSMutableDictionary dictionary];
        NSURL *url = [NSURL URLWithString:rootUrl];
        self.rootUrl = [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];
        self.rootNode = [[Node alloc] initWithUrl:@"/"];
        [self addNode:self.rootNode];
    }
    return self;
}

- (instancetype)init
{
    return [self initGraphWithRootLink:nil];
}

- (void)addNode:(Node *)node
{
    if (node && node.url) {
        [self.nodes setObject:node forKey:node.url];
    }
}

- (Node*)nodeForUrl:(NSString*)url
{
    return [self.nodes objectForKey:url];
}

- (void)buildSiteMap
{
    [self breadthFirstSearchFromNode:self.rootNode maxIterations:NSUIntegerMax];
}

- (void)buildSiteMapWithMaxIterations:(NSUInteger)maxIter
{
    [self breadthFirstSearchFromNode:self.rootNode maxIterations:maxIter];
}

- (void)breadthFirstSearchFromNode:(Node*)node maxIterations:(NSUInteger)maxIterations
{
    NSLog(@"Breath-first-search STARTS");
    NSMutableSet *visitedNodes = [NSMutableSet set];
    NSMutableArray *queue = [NSMutableArray arrayWithObject:node];
    NSUInteger iteration = 0;
    while (queue.count > 0 && iteration++ < maxIterations) {
        Node *currentNode = queue.firstObject;
        
        [self parseNode:currentNode];
        
        [visitedNodes addObject:currentNode];
        [queue removeObject:currentNode];
        for (NSString *nodeUrl in currentNode.edges) {
            Node *newNode = [self nodeForUrl:nodeUrl];
            if (newNode && ![visitedNodes containsObject:newNode] && ![queue containsObject:newNode]) {
                [queue addObject:newNode];
            }
        }
    }
    NSLog(@"SEARCH ENDS");
}

- (void)buildNextGeneration
{
    NSLog(@"Next Generation breath-first-search STARTS");
    NSDictionary *graphCopy = [self.nodes copy];
    NSMutableSet *visitedNodes = [NSMutableSet set];
    NSMutableArray *queue = [NSMutableArray arrayWithObject:self.rootNode];
    while (queue.count > 0) {
        Node *currentNode = queue.firstObject;
        
        [self parseNode:currentNode];
        
        [visitedNodes addObject:currentNode];
        [queue removeObject:currentNode];
        for (NSString *nodeUrl in currentNode.edges) {
            Node *newNode = [graphCopy objectForKey:nodeUrl];
            if (newNode && ![visitedNodes containsObject:newNode] && ![queue containsObject:newNode]) {
                [queue addObject:newNode];
            }
        }
    }
    NSLog(@"%@", @(self.nodes.count));
    NSLog(@"SEARCH ENDS");
}


- (void)parseNode:(Node *)node
{
    if (node.wasParsed) {
        return;
    }
    NSLog(@"%@", node.url);
    NSString *fullUrl = [self.rootUrl stringByAppendingString:node.url];
    NSData *dataFromURL = [NSData dataWithContentsOfURL:[NSURL URLWithString:fullUrl]];
    if (dataFromURL) {
        TFHpple *parser = [TFHpple hppleWithHTMLData:dataFromURL];
        
        NSString *XpathQueryString = @"//a[@href and starts-with(@href, \"/\") = 1]";
        NSArray *nodesFromUrl = [parser searchWithXPathQuery:XpathQueryString];
        for (TFHppleElement *element in nodesFromUrl) {
            NSString *url = [element objectForKey:@"href"];
            NSRange range;
            range = [url rangeOfString:@"?"];
            if (range.location != NSNotFound) {
                url = [url substringToIndex:range.location];
            }
            range = [url rangeOfString:@"#"];
            if (range.location != NSNotFound) {
                url = [url substringToIndex:range.location];
            }
            url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            Node *nextNode = [self nodeForUrl:url];
            if (!nextNode) {
                nextNode = [[Node alloc] initWithUrl:url];
            }
            [self addNode:nextNode];
            [node addEdgeToNode:nextNode];
        }
        node.wasParsed = YES;
    }
}

- (NSArray*)firstGenerationFromNode:(Node*)node
{
    return [self.nodes objectsForKeys:[node.edges allObjects] notFoundMarker:[[Node alloc] init]];
}

@end
