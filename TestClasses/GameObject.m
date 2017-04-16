//
//  GameObject.m
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#include "GameObject.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface GameObject() {
    
}

- (GLKMatrix4) makeRotationMatrix;

@end

@implementation GameObject

// Private Mehtods with above Interface

- (GLKMatrix4) makeRotationMatrix {
    GLKMatrix4 rotMatrix = GLKMatrix4MakeXRotation(_rot.x);
    rotMatrix = GLKMatrix4RotateY(rotMatrix, _rot.y);
    return GLKMatrix4RotateZ(rotMatrix, _rot.z);
}

- (id) init {
    self = [super init];
    if (self) {
        _direction = 0.5;
    }
    return self;
}

// Public Methods in Header File

- (id) init : (NSString*) name : (GLKVector3) pos : (GLKVector3) rot : (GLKVector3) scale : (NSMutableArray*) array {
    self = [super init];
    if (self) {
        _ID = name;
        _pos = pos;
        _rot = rot;
        _scale = scale;
        [self initializeModelView];
        _renderer = nil;
        _childGameObjects = array;
        
    }
    return self;
}

- (void) update : (GLKMatrix4) projection : (GLKMatrix4) baseModelView : (float) time : (GLKMatrix4) matrix {
    [self initializeModelView];
    if ([_ID isEqualToString:@"RightWing"]) {
        _modelView = GLKMatrix4Rotate(_modelView, _rotation, 0.0f, 0.0f, 1.0f);
        if (_rotation >= 0.7f || _rotation <= 0.0f) {
            _direction *= -1.0f;
        }
        _rotation += _direction * time;
        if (_rotation > 0.7f) {
            _rotation = 0.7f;
        } else if (_rotation < 0.0f) {
            _rotation = 0.0f;
        }
    } else if ([_ID isEqualToString:@"CharacterBody2"]) {
        _modelView = GLKMatrix4Rotate(_modelView, _rotation, 1.0f, 0.0f, 0.0f);
        _rotation += 1.0f * time;
    } else if ([_ID isEqualToString:@"LeftWing"]) {
        _modelView = GLKMatrix4Rotate(_modelView, _rotation, 0.0f, 0.0f, 1.0f);
        if (_rotation >= 0.0f || _rotation <= -0.7f) {
            _direction *= -1.0f;
        }
        _rotation += _direction * time;
        if (_rotation > 0.0f) {
            _rotation = 0.0f;
        } else if (_rotation < -0.7f) {
            _rotation = -0.7f;
        }
    }
    
    _modelView = GLKMatrix4Multiply(matrix, _modelView);
    
    if (_childGameObjects != nil) {
        for (GameObject *object in _childGameObjects) {
            [object update:projection :baseModelView : time : _modelView];
        }
    }
    _modelView = GLKMatrix4Multiply(baseModelView, _modelView);
    if (_renderer) {
        [_renderer setNormalView : GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_modelView), NULL)];
        
        [_renderer setModelProjection : GLKMatrix4Multiply(projection, _modelView)];
    }
}

- (void) setupArrays {
    if (_childGameObjects != nil) {
        for (GameObject *object in _childGameObjects) {
            [object setupArrays];
        }
    }
    if (_renderer) {
        glGenVertexArraysOES(1, &_renderer->_vertexArray);
        glBindVertexArrayOES(_renderer->_vertexArray);
        
        glGenBuffers(1, _renderer->_vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, _renderer->_vertexBuffer[0]);
        glBufferData(GL_ARRAY_BUFFER, [_renderer getSizeOfVertices], [_renderer getVertices], GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 4, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 4, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(16));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 40, BUFFER_OFFSET(32));
        
        glBindVertexArrayOES(0);
    }
}

- (void) initializeModelView {
    _modelView = GLKMatrix4Identity;
    _modelView = [self makeRotationMatrix];
    _modelView = GLKMatrix4ScaleWithVector3(_modelView, _scale);
    _modelView = GLKMatrix4TranslateWithVector3(_modelView, _pos);
}


#pragma mark - Getters
- (GLKMatrix4) getModelView {
    return _modelView;
}

- (RenderClass*) getRenderer {
    return _renderer;
}

- (NSMutableArray*) getChildGameObjects {
    return _childGameObjects;
}

#pragma mark - Setters
- (void) setModelView : (GLKMatrix4) modelView{
    _modelView = modelView;
}


@end
