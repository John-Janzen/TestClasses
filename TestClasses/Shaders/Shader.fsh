//
//  Shader.fsh
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//
precision mediump float;
varying lowp vec4 colorVarying;
varying vec2 TexCoordOut;
uniform sampler2D Texture;

void main()
{
    gl_FragColor = colorVarying * texture2D(Texture, TexCoordOut);
}
