//
//  Model.m
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Model.h"

@implementation Model

- (id) init : (NSString*) name : (GLKVector3) pos : (GLKVector3) rot : (GLKVector3) scale : (RenderClass*) renderer : (NSMutableArray*) array {
    self = [super init];
    if (self) {
        _ID = name;
        _pos = pos;
        _rot = rot;
        _scale = scale;
        [super initializeModelView];
        _renderer = renderer;
        _childGameObjects = array;
        
    }
    return self;
}

@end
