//
//  ViewController.m
//  SceneKit - 18碰撞检测
//
//  Created by ShiWen on 2017/7/26.
//  Copyright © 2017年 ShiWen. All rights reserved.
//

#import "ViewController.h"
#import <SceneKit/SceneKit.h>

typedef enum : NSUInteger {
    CollisionDetectionMaskBox = 1,
    CollisionDetectionMaskSphere = 2,
    CollisionDetectionMaskFloor = 3
} CollisionDetectionMask;

@interface ViewController ()<SCNPhysicsContactDelegate>

@property (nonatomic,strong) SCNView *mScnView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.mScnView];
    
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 0, 50);
    [self.mScnView.scene.rootNode addChildNode:cameraNode];
    

    SCNNode *floorNode = [SCNNode nodeWithGeometry:[SCNFloor floor]];
    floorNode.geometry.firstMaterial.diffuse.contents = @"floor.jpg";
    floorNode.position = SCNVector3Make(0, -10, 0);
    floorNode.physicsBody = [SCNPhysicsBody staticBody];
    [self.mScnView.scene.rootNode addChildNode:floorNode];
    
    SCNBox *box = [SCNBox boxWithWidth:4 height:4 length:4 chamferRadius:0];
    box.firstMaterial.diffuse.contents = [UIColor redColor];
    SCNNode *boxNode = [SCNNode nodeWithGeometry:box];
    boxNode.position = SCNVector3Make(0, -8, 0);
    boxNode.physicsBody = [SCNPhysicsBody dynamicBody];
    [self.mScnView.scene.rootNode addChildNode:boxNode];
    
    SCNNode *sphereNode = [SCNNode nodeWithGeometry:[SCNSphere sphereWithRadius:2]];
    sphereNode.geometry.firstMaterial.diffuse.contents = [UIColor orangeColor];
    sphereNode.physicsBody = [SCNPhysicsBody dynamicBody];
    sphereNode.position = SCNVector3Make(0, 20, 0);
    [self.mScnView.scene.rootNode addChildNode:sphereNode];
    self.mScnView.scene.physicsWorld.contactDelegate = self;
//    给要碰撞的物体做标记 用于在代理中获取节点时候使用
    boxNode.physicsBody.categoryBitMask = CollisionDetectionMaskBox;
    sphereNode.physicsBody.categoryBitMask = CollisionDetectionMaskSphere;
//    告诉物理引擎，球碰撞盒子时候告诉我
    sphereNode.physicsBody.contactTestBitMask = CollisionDetectionMaskBox|CollisionDetectionMaskSphere;
    
//    给两SCNView添加手势，当点击节点时候，告诉我们，改变节点颜色
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    NSMutableArray *gestureRecongizers = [[NSMutableArray alloc]init];
    [gestureRecongizers addObject:tapgesture];
//    获取系统默认手势并放入数组
    [gestureRecongizers addObjectsFromArray:self.mScnView.gestureRecognizers];
    self.mScnView.gestureRecognizers = gestureRecongizers;
    [self.mScnView addGestureRecognizer:tapgesture];
    
    
}
-(void)physicsWorld:(SCNPhysicsWorld *)world didBeginContact:(SCNPhysicsContact *)contact{
    NSLog(@"开始碰撞");
}
-(void)physicsWorld:(SCNPhysicsWorld *)world didUpdateContact:(SCNPhysicsContact *)contact{
    SCNNode *nodeA = contact.nodeA;
    SCNNode *nodeB = contact.nodeB;
    
    if (nodeA.physicsBody.categoryBitMask == CollisionDetectionMaskBox) {
        NSLog(@"盒子%@",nodeA);
        NSLog(@"球%@",nodeB);
    }else{
        NSLog(@"盒子%@",nodeB);
        NSLog(@"球%@",nodeA);;
    }
    
    
}
-(void)physicsWorld:(SCNPhysicsWorld *)world didEndContact:(SCNPhysicsContact *)contact{
    NSLog(@"结束");
}
-(void)handleTap:(UIGestureRecognizer *)gesture{
    CGPoint touchPoint = [gesture locationInView:self.mScnView];
    NSArray *hitResules = [self.mScnView hitTest:touchPoint options:nil];
    if (hitResules.count > 0) {
        SCNHitTestResult *result = hitResules.firstObject;
//        获取点击的节点
//        SCNNode *resultNode = result.node;
        SCNMaterial *material = result.node.geometry.firstMaterial;
        material.diffuse.contents = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
        
    }
}
-(SCNView*)mScnView{
    if (!_mScnView) {
        _mScnView = [[SCNView alloc] initWithFrame:self.view.bounds];
        _mScnView.backgroundColor = [UIColor blackColor];
        _mScnView.allowsCameraControl = YES;
        _mScnView.scene = [SCNScene scene];
    }
    return _mScnView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
