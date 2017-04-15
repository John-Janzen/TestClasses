//
//  RenderClass.m
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "RenderClass.h"

@implementation RenderClass

#pragma mark - Getters
- (GLfloat*) getVertices {
    return _vertices;
}

- (GLKMatrix3) getNormalView {
    return _normalMatrix;
}

- (GLKMatrix4) getModelProjection {
    return _modelProjection;
}

- (GLuint) getSizeOfVertices {
    return _sizeVertices;
}

- (GLuint) getIndicesNum {
    return _indicesNum;
}

#pragma mark - Setters
- (void) setVertices : (GLfloat*) verts{
    _vertices = verts;
}

- (void) setNormalView : (GLKMatrix3) normalView {
    _normalMatrix = normalView;
}

- (void) setModelProjection : (GLKMatrix4) modelProjection {
    _modelProjection = modelProjection;
}

- (void) setSizeOfVertices : (GLuint) size {
    _sizeVertices = size;
}

- (void) setIndicesNum:(GLuint)size {
    _indicesNum = size;
}
@end
