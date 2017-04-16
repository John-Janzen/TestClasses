//
//  RenderClass.h
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef RenderClass_h
#define RenderClass_h
#import <GLKit/GLKit.h>

@interface RenderClass : NSObject {
    GLfloat *_vertices;
    GLuint _sizeVertices, _indicesNum;
    GLKMatrix3 _normalMatrix;
    GLKMatrix4 _modelProjection;
    GLuint _texture;
    @public
    GLuint _vertexArray;
    GLuint _vertexBuffer[1];
}

- (id) init : (GLuint) texture : (GLfloat*) verts : (GLuint) size : (GLuint) indicesNum;

#pragma mark - Getters
- (GLfloat*) getVertices;
- (GLKMatrix3) getNormalView;
- (GLKMatrix4) getModelProjection;
- (GLuint) getSizeOfVertices;
- (GLuint) getIndicesNum;
- (GLuint) getTexture;

#pragma mark - Setters
- (void) setVertices : (GLfloat*) verts;
- (void) setNormalView : (GLKMatrix3) normalView;
- (void) setModelProjection : (GLKMatrix4) modelProjection;
- (void) setSizeOfVertices : (GLuint) size;
- (void) setIndicesNum : (GLuint) size;

@end

#endif /* RenderClass_h */
