//
//  Model.h
//  TestClasses
//
//  Created by John Janzen on 2017-04-15.
//  Copyright © 2017 John Janzen. All rights reserved.
//

#ifndef Model_h
#define Model_h
#include "GameObject.h"

@interface Model : GameObject

- (id) init : (NSString*) name : (GLKVector3) pos : (GLKVector3) rot : (GLKVector3) scale : (RenderClass*) renderer : (NSMutableArray*) array;

@end


#endif /* Model_h */
