//
//  SGGViewController.h
//  SimpleGLKitGame
//
//  Created by Anthony Baker on 3/5/14.
//  Copyright (c) 2014 com.anthony.baker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>


@interface SGGViewController : GLKViewController

- (void)addTarget;
-(void) movePlayerWithData: (CMAccelerometerData*) accelerometerData;

@end
