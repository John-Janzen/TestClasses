//
//  GameViewController.m
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#include "Cube.h"
#include "Model.h"
#include "TextureLoad.h"
#include "OBJImporter.h"

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface GameViewController () {
    GLuint _program;
    
    float _rotation;
    NSMutableArray *GameWorldObjects;
    TextureLoad *textureLoader;
    OBJImporter *objImport;
    GLuint texture[1];
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;
- (void)setupGameWorldObjects;

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    textureLoader = [[TextureLoad alloc] init];
    objImport = [[OBJImporter alloc] init];
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    glEnable(GL_DEPTH_TEST);
    glFrontFace(GL_CCW);
    glEnable(GL_CULL_FACE);
    
    GameWorldObjects = [[NSMutableArray alloc] init];
    [self setupGameWorldObjects];
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    for (GameObject *object in GameWorldObjects) {
        if ([object getRenderer]) {
            glDeleteBuffers(1, [object getRenderer]->_vertexBuffer);
            glDeleteVertexArraysOES(1, &[object getRenderer]->_vertexArray);
        }
    }
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

- (void) setupGameWorldObjects
{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    [objects addObject:[[Model alloc] init : @"LeftWing"
                                          : GLKVector3Make(0.7f, 0.0f, 0.1f)
                                          : GLKVector3Make(0.0f, 1.0f, 0.0f)
                                          : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                          : [[RenderClass alloc] init : [textureLoader loadTexture:@"characterleftwing.jpg"]
                                                                      : [objImport customStringFromFile:@"characterleftwing" :@"obj"]
                                                                      : objImport->_faces.count * 10 : objImport->_faces.count]
                                          : nil]];
    [objects addObject:[[Model alloc] init : @"RightWing"
                                           : GLKVector3Make(-0.8f, 0.0f, -0.1f)
                                           : GLKVector3Make(0.0f, -1.0f, 0.0f)
                                           : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                           : [[RenderClass alloc] init : [textureLoader loadTexture:@"characterrightwing.jpg"]
                                                                       : [objImport customStringFromFile:@"characterrightwing" :@"obj"]
                                                                       : objImport->_faces.count * 10 : objImport->_faces.count]
                                           : nil]];
    [objects addObject:[[Model alloc] init : @"CharacterBody"
                                           : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                           : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                           : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                           : [[RenderClass alloc] init: [textureLoader loadTexture:@"characterbody.jpg"]
                                                                      : [objImport customStringFromFile:@"characterbody" :@"obj"]
                                                                      : objImport->_faces.count * 10 : objImport->_faces.count]
                                           : nil]];
    [GameWorldObjects addObject:[[GameObject alloc] init : @"GlobalCharacter"
                                                         : GLKVector3Make(0.0f, 0.0f, 0.0f)
                                                         : GLKVector3Make(M_PI_2, 0.0f, 0.0f)
                                                         : GLKVector3Make(1.0f, 1.0f, 1.0f)
                                                         : objects]];
    
    for (GameObject *object in GameWorldObjects) {
        [object setupArrays];
    }
    glActiveTexture(GL_TEXTURE0);
    glUniform1i(uniforms[UNIFORM_TEXTURE], 0);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabs(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -10.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    for (GameObject *object in GameWorldObjects) {
        [object update : projectionMatrix : baseModelViewMatrix : self.timeSinceLastUpdate : GLKMatrix4Identity];
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render the object again with ES2
    glUseProgram(_program);
    
    for (GameObject *object in GameWorldObjects) {
        [self glkRectDraw : object];
    }
}

- (void) glkRectDraw : (GameObject*) object{
    if ([object getChildGameObjects] != nil) {
        for (GameObject *object2 in [object getChildGameObjects]) {
            [self glkRectDraw : object2];
        }
    }
    if ([object getRenderer]) {
        glBindTexture(GL_TEXTURE_2D, [[object getRenderer] getTexture]);
        
        glBindVertexArrayOES([object getRenderer]->_vertexArray);
        
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, [[object getRenderer] getModelProjection].m);
        glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, [[object getRenderer]getNormalView].m);
        
        glDrawArrays(GL_TRIANGLES, 0, [[object getRenderer] getIndicesNum]);
    }
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "TexCoordIn");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "Texture");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
