//
//  ViewController.m
//  Graph
//
//  Created by Inna Labuns'ka on 13.05.15.
//  Copyright (c) 2015 Inna Labuns'ka. All rights reserved.
//

#import "ViewController.h"
#import "NodeView.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

static NSUInteger const NodeSize = 30;
static NSUInteger const NodeDistance = 5;

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Graph *graph;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic) NSUInteger gestureCount;
@property (nonatomic) BOOL buildInProgress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gestureCount = 0;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    self.scrollView.contentSize = self.containerView.frame.size;
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchWithGestureRecognizer:)];
    [self.scrollView addGestureRecognizer:pinchGestureRecognizer];
    self.graph = [[Graph alloc] initGraphWithRootLink:@"http://www.raywenderlich.com"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateNodesView];
}

- (void)updateNodesView
{
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    Node *rootNode = self.graph.rootNode;
    
    NSArray *firstGeneration = [self.graph firstGenerationFromNode:rootNode];
    if (!firstGeneration.count) {
        [self.containerView setFrame:self.view.frame];
        [self.scrollView setContentSize:self.view.frame.size];
        NodeView *rootNodeView = [[NodeView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, NodeSize, NodeSize)];
        rootNodeView.node = rootNode;
        [self.containerView addSubview:rootNodeView];
    } else {
        double maxRadius = 1500;
        [self.containerView setFrame:CGRectMake(0, 0, maxRadius, maxRadius)];
        [self.scrollView setContentSize:CGSizeMake(maxRadius, maxRadius)];

        NodeView *nodeView = nil;
        nodeView = [[NodeView alloc] initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
        nodeView.center = CGPointMake(maxRadius/2, maxRadius/2);
        nodeView.level = 0;
        nodeView.node = rootNode;
        [self.containerView addSubview:nodeView];
        
        NSMutableArray *queue = [NSMutableArray arrayWithObject:nodeView];
        NSMutableSet *visited = [NSMutableSet setWithObject:nodeView.node.url];
        while (queue.count) {
            NodeView *currentNodeView = queue.firstObject;
            [queue removeObject:currentNodeView];
            
            NSArray *nodes = [self.graph firstGenerationFromNode:currentNodeView.node];
            nodes = [nodes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF.url in %@)", visited]];
            double scale = currentNodeView.level? pow(0.5, currentNodeView.level): 1;
            double radius = scale * [self circleRadiusForNodeCount:nodes.count];
            double dAlpha = 2.0 * M_PI / nodes.count;
            double alpha = 0;
            for (Node *node in nodes) {
                nodeView = [[NodeView alloc] initWithFrame:CGRectMake(0, 0, NodeSize, NodeSize)];
                
                CGPoint offset = CGPointMake(radius * cos(alpha), radius * sin(alpha));
                alpha += dAlpha;
                nodeView.center = CGPointMake(currentNodeView.center.x + offset.x, currentNodeView.center.y + offset.y);
                nodeView.level = currentNodeView.level + 1;
                nodeView.node = node;
                [nodeView setTransform:CGAffineTransformMakeScale(scale * 0.5, scale * 0.5)];
                [self.containerView addSubview:nodeView];
                [visited addObject:node.url];
                [queue addObject:nodeView];
            }
        }
    }
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    NSLog(@"Line tap was here: %@", recognizer.view);
}
- (void)handleSingleTapNodeView:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Node tap happened: x = %@, y = %@", @(recognizer.view.center.x), @(recognizer.view.center.y));
}

- (float)circleRadiusForNodeCount:(NSUInteger)nodeCount
{
    return 0.5 * M_1_PI * nodeCount * (NodeSize + NodeDistance);
}

- (NSUInteger)nodesCountForRadius:(float)radius
{
    return 2 * M_PI * radius / (NodeSize + NodeDistance);
}

-(void)handlePinchWithGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
 
        switch (pinchGestureRecognizer.state) {
        case UIGestureRecognizerStateRecognized: {
            NSLog(@">>>>>>>>>>>>>>>>>>>>>>>");
            self.gestureCount++;
            [self asyncBuildNextGeneration];
        } break;

        default: {
        } break;
    }
}

- (void)asyncBuildNextGeneration
{
    if (self.gestureCount > 0 && !self.buildInProgress) {
        self.buildInProgress = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.graph buildNextGeneration];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.gestureCount--;
                self.buildInProgress = NO;
                [self updateNodesView];
                [self asyncBuildNextGeneration];
            });
        });
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return nil;//self.containerView;
}

@end
