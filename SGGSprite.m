//
//  SGGSprite.m
//  SimpleGLKitGame
//
//  Created by Anthony Baker on 3/6/14.
//  Copyright (c) 2014 com.anthony.baker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGGSprite.h"


typedef struct {
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct {
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;


@interface SGGSprite()

@property (strong) GLKBaseEffect * effect;
@property (assign) TexturedQuad quad;
@property (strong) GLKTextureInfo * textureInfo;

@end

@implementation SGGSprite

@synthesize effect = _effect;
@synthesize quad = _quad;
@synthesize textureInfo = _textureInfo;
@synthesize position = _position;
@synthesize xacceleration = _xacceleration;
@synthesize rotation = _rotation;
@synthesize lifespan = _lifespan;
@synthesize contentSize = _contentSize;
@synthesize moveVelocity = _moveVelocity;


- (id)initWithFile:(NSString *)fileName effect:(GLKBaseEffect *)effect {
    if ((self = [super init])) {
        // 1
        
        @autoreleasepool{
             
        self.effect = effect;
        
        // 2
        NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES],
                                  GLKTextureLoaderOriginBottomLeft,
                                  nil];
        
        // 3
        
        
            NSError * error;
            NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
             
             // 4
             self.textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
             if (self.textureInfo == nil) {
                 NSLog(@"Error loading file: %@", [error localizedDescription]);
                 return nil;
             }
            
            //setting to nil so ARC will release from memory
             path = nil;
             error = nil;
       
    
        self.contentSize = CGSizeMake(self.textureInfo.width, self.textureInfo.height);
        
        TexturedQuad newQuad;
        
        newQuad.bl.geometryVertex = CGPointMake(0, 0);
        newQuad.br.geometryVertex = CGPointMake(self.textureInfo.width, 0);
        newQuad.tl.geometryVertex = CGPointMake(0, self.textureInfo.height);
        newQuad.tr.geometryVertex = CGPointMake(self.textureInfo.width, self.textureInfo.height);
        
        newQuad.bl.textureVertex = CGPointMake(0, 0);
        newQuad.br.textureVertex = CGPointMake(1, 0);
        newQuad.tl.textureVertex = CGPointMake(0, 1);
        newQuad.tr.textureVertex = CGPointMake(1, 1);
        self.quad = newQuad;
        
        //newQuad will be freed on leaving scope.
            
        }//end @autoreleasepool
        
    }
    return self;
}

- (CGRect)boundingBox {
    CGRect rect = CGRectMake(self.position.x, self.position.y, self.contentSize.width, self.contentSize.height);
    return rect;
}

- (GLKMatrix4) modelMatrix {
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, self.position.x, self.position.y, 0);
    modelMatrix = GLKMatrix4Translate(modelMatrix, -self.contentSize.width/2, -self.contentSize.height/2, 0);

    modelMatrix = GLKMatrix4RotateZ(modelMatrix, self.rotation);
    
    return modelMatrix;
}

- (void)update:(float)dt {
    GLKVector2 curMove = GLKVector2MultiplyScalar(self.moveVelocity, dt);
    
    self.position = GLKVector2Add(self.position, curMove);
}

- (void)render {
    
    // 1
    self.effect.texture2d0.name = self.textureInfo.name;
    self.effect.texture2d0.enabled = YES;

    self.effect.transform.modelviewMatrix = self.modelMatrix;
    
    // 2
    [self.effect prepareToDraw];
    
    // 3
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    // 4
    long offset = (long)&_quad;
    
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    
    // 5
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}


@end