//
//  Shader.vsh
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//
precision mediump float;
attribute vec4 position;
attribute vec3 normal;
attribute vec2 TexCoordIn;

varying vec2 TexCoordOut;
varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;

void main()
{
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    TexCoordOut = TexCoordIn;
    
    gl_Position = modelViewProjectionMatrix * position;
}
