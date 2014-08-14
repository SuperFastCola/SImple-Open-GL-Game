//
//  SGGViewController.m
//  SimpleGLKitGame
//
//  Created by Anthony Baker on 3/5/14.
//  Copyright (c) 2014 com.anthony.baker. All rights reserved.
//

#import "SGGViewController.h"
#import "SGGSprite.h"
#import <CoreMotion/CoreMotion.h>


@interface SGGViewController ()
    @property (strong, nonatomic) EAGLContext *context;
    @property (strong) GLKBaseEffect * effect;
    @property (strong) SGGSprite * player;
    @property (nonatomic) NSMutableArray * children;
    @property (nonatomic) float timeSinceLastSpawn;

    @property (nonatomic) NSMutableArray *projectiles;
    @property (nonatomic) NSMutableArray *targets;
    @property (nonatomic) NSMutableArray * projectilesToDelete;
    @property (nonatomic) NSMutableArray * targetsToDelete;
    @property (nonatomic) int targetsDestroyed;
    @property (strong) CMMotionManager * motionManager;
    @property (nonatomic)  CGFloat xAcceleration;
    @property (nonatomic) float pointsPerSec;

@end

@implementation SGGViewController

@synthesize context = _context;
@synthesize player = _player;
@synthesize children = _children;
@synthesize projectiles = _projectiles;
@synthesize targets = _targets;
@synthesize projectilesToDelete = _projectilesToDelete;
@synthesize targetsToDelete = _targetsToDelete;
@synthesize timeSinceLastSpawn = _timeSinceLastSpawn;
@synthesize motionManager = _motionManager;
@synthesize xAcceleration = _xAcceleration;
@synthesize pointsPerSec = _pointsPerSec;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    @autoreleasepool {
           
        GLKView *view = (GLKView *)self.view;
        view.context = self.context;
        
        [EAGLContext setCurrentContext:self.context];
        
        self.effect = [[GLKBaseEffect alloc] init];
        
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, 480, 0, 320, -1024, 1024);
        self.effect.transform.projectionMatrix = projectionMatrix;
        
        self.player = [[SGGSprite alloc] initWithFile:@"suki_game_space.png" effect:self.effect];
        
        self.player.position = GLKVector2Make(self.player.contentSize.width/2, 160);
        
        self.children = [NSMutableArray array];
        [self.children addObject:self.player];
        //self.player.moveVelocity = GLKVector2Make(-2, -2);
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [self.view addGestureRecognizer:tapRecognizer];
        
        self.targets = [NSMutableArray array];
        self.projectiles = [NSMutableArray array];
        self.projectilesToDelete = [NSMutableArray array];
        self.targetsToDelete = [NSMutableArray array];
        
        //initialize motion manager
        self.motionManager = [[CMMotionManager alloc] init];
        //self.motionManager.accelerometerUpdateInterval = 0.2;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 
                                                 [self movePlayerWithData:accelerometerData];
                                                 
                                             }];
        
    }//end @autoreleasepool

}

-(void) movePlayerWithData: (CMAccelerometerData*) accelerometerData {
    
    #define kFilteringFactor 0.1
    #define kRestAccelX -0.6
    #define kShipMaxPointsPerSec (self.view.bounds.size.height*0.5)
    #define kMaxDiffX 0.2
    
    UIAccelerationValue rollingX = 0, rollingY = 0, rollingZ = 0;
    
    rollingX = (accelerometerData.acceleration.x * kFilteringFactor) + (rollingX * (1.0 - kFilteringFactor));
    rollingY = (accelerometerData.acceleration.y * kFilteringFactor) + (rollingY * (1.0 - kFilteringFactor));
    rollingZ = (accelerometerData.acceleration.z * kFilteringFactor) + (rollingZ * (1.0 - kFilteringFactor));
    
    float accelX = accelerometerData.acceleration.x - rollingX;
//    float accelY = accelerometerData.acceleration.y - rollingY;
//    float accelZ = accelerometerData.acceleration.z - rollingZ;
    
    float accelDiff = accelX - kRestAccelX;
    float accelFraction = accelDiff / kMaxDiffX;
    _pointsPerSec = kShipMaxPointsPerSec * accelFraction;
    
    float percentOfAcceleration =  accelerometerData.acceleration.x * 0.08;
    percentOfAcceleration *= (percentOfAcceleration<0)?-1:1;
    
    float centerPoint = self.view.bounds.size.height/2;
    float acceleration = ((centerPoint - self.player.position.y)*2) * .05;
    
    acceleration *= (acceleration<0)?-1:1; 
    
    float newY = self.player.position.y + acceleration;
    
    GLKVector2 curMove = GLKVector2MultiplyScalar(GLKVector2Make(0,newY), accelerometerData.acceleration.x * 0.08);
    self.player.position = GLKVector2Add(self.player.position, curMove);
    
    
//    float position = self.player.position.y;
//    float topbound = 320.00 - self.player.contentSize.width/2;
//    float bottombound = self.player.contentSize.width/2;
//    
//    if(position >= topbound){
//        self.player.position = GLKVector2Make(self.player.contentSize.width/2, topbound - 3);
//    }
//    else if(position <= bottombound){
//                self.player.position = GLKVector2Make(self.player.contentSize.width/2, bottombound + 3);
//    }
//    else{
//        
//    }
//    
//    GLKVector2 curMove = GLKVector2MultiplyScalar(GLKVector2Make(0,position), accelerometerData.acceleration.x * 0.08);
//    self.player.position = GLKVector2Add(self.player.position, curMove);

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    @autoreleasepool {
        for (SGGSprite __strong * sprite in self.children) {
            [sprite render];
            sprite = nil;
        }
    }//@autoreleasepool
}

- (void)addTarget {
    SGGSprite * target = [[SGGSprite alloc] initWithFile:@"suki_game_asteroid.png" effect:self.effect];
    
    [self.children addObject:target];
    
    int minY = target.contentSize.height/2;
    int maxY = 320 - target.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    target.position = GLKVector2Make(480 + (target.contentSize.width/2), actualY);
    target.lifespan = 0;
    
    int minVelocity = 480.0/4.0;
    int maxVelocity = 480.0/2.0;
    int rangeVelocity = maxVelocity - minVelocity;
    int actualVelocity = (arc4random() % rangeVelocity) + minVelocity;
    
    target.moveVelocity = GLKVector2Make(-actualVelocity, 0);
    
    [self.targets addObject:target];

}

- (void)update {
    @autoreleasepool {

 
        for (SGGSprite * projectile in self.projectiles) {
            
            for (SGGSprite * target in self.targets) {
                if (CGRectIntersectsRect(projectile.boundingBox, target.boundingBox)) {
                    [self.targetsToDelete addObject:target];
                    [self.projectilesToDelete addObject:projectile];
                }
            }
            
            if(!CGRectIntersectsRect(projectile.boundingBox,self.view.bounds)){
                [self.projectilesToDelete addObject:projectile];
            }
            
        }
        
        for (SGGSprite __strong * projectile in self.projectilesToDelete) {
            [self.projectiles removeObject:projectile];
            [self.children removeObject:projectile];
            projectile = nil;
        }
        
        for (SGGSprite * target in self.targets) {
            target.lifespan += self.timeSinceLastUpdate;
            
            if(!CGRectIntersectsRect(target.boundingBox,self.view.bounds) && target.lifespan>3.0){
                //NSLog(@"Target Off Screen");
                [self.targetsToDelete addObject:target];
            }
        }
        
        for (SGGSprite __strong * target in self.targetsToDelete) {
            [self.targets removeObject:target];
            [self.children removeObject:target];
            target  = nil;
            _targetsDestroyed++;
        }


        self.timeSinceLastSpawn += self.timeSinceLastUpdate;
        if (self.timeSinceLastSpawn > 1.0) {
            self.timeSinceLastSpawn = 0;
            [self addTarget];
        }
        
        for (SGGSprite * sprite in self.children) {
            [sprite update:self.timeSinceLastUpdate];
        }
        
    }//end @autoreleasepool
    
    


    
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    
    // 1
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];

    touchLocation = CGPointMake(touchLocation.x, 320 - touchLocation.y);
    
    // 2
    GLKVector2 target = GLKVector2Make(touchLocation.x, touchLocation.y);
    GLKVector2 offset = GLKVector2Subtract(target, self.player.position);
    

    float dy = touchLocation.y - self.player.position.y;
    float dx = touchLocation.x - self.player.position.x;
    float rotation = atan2(dy,dx);
    
    
    // 3
    GLKVector2 normalizedOffset = GLKVector2Normalize(offset);
    
    // 4
    static float POINTS_PER_SECOND = 480;
    GLKVector2 moveVelocity = GLKVector2MultiplyScalar(normalizedOffset, POINTS_PER_SECOND);
    
    // 5
    SGGSprite * sprite = [[SGGSprite alloc] initWithFile:@"suki_game_rocket.png" effect:self.effect];
    sprite.position = self.player.position;
    sprite.rotation = rotation;
    sprite.moveVelocity = moveVelocity;
    
    [self.children addObject:sprite];
    [self.projectiles addObject:sprite];
    
    //NSLog(@"%i",[self.projectiles count]);
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeLeft;
}

@end
