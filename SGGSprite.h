//
//  SGGSprite.h
//  SimpleGLKitGame
//
//  Created by Anthony Baker on 3/6/14.
//  Copyright (c) 2014 com.anthony.baker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <stdio.h> //required to use offsetof in open GL functions


@interface SGGSprite : NSObject

@property (assign) GLKVector2 position;
@property (assign) float rotation;
@property (assign) float lifespan;
@property (assign) float xacceleration;
@property (assign) CGSize contentSize;
@property (assign) GLKVector2 moveVelocity;


- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (GLKMatrix4) modelMatrix;
- (void)update:(float)dt;
- (void)render;
- (CGRect)boundingBox;

@end
