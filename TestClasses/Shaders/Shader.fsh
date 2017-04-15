//
//  Shader.fsh
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
