//
//  GameObject.h
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef GameObject_h
#define GameObject_h
#import <GLKit/GLKit.h>
#import "RenderClass.h"

@interface GameObject : NSObject {
    NSString *_ID;
    RenderClass *_renderer;
    NSMutableArray *_childGameObjects;
    GLKVector3 _pos, _rot, _scale;
    GLKMatrix4 _modelView;
    float _rotation, _direction;
}

- (void) update : (GLKMatrix4) projection : (GLKMatrix4) baseModelView : (float) time : (GLKMatrix4) matrix;
- (void) setupArrays;
- (void) initializeModelView;

// Getters
- (GLKMatrix4) getModelView;
- (RenderClass*) getRenderer;
- (NSMutableArray*) getChildGameObjects;

// Setter
- (void) setModelView : (GLKMatrix4) modelView;

@end

#endif /* GameObject_h */
