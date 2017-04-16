//
//  OBJImporter.h
//  DownTheAbyss
//
//  Created by John Janzen on 2017-03-25.
//  Copyright © 2017 JRCT. All rights reserved.
//

#ifndef OBJImporter_h
#define OBJImporter_h
#import <GLKit/GLKit.h>

@interface OBJImporter : NSObject {
@public
    NSMutableArray *_Vertex;
    NSMutableArray *_VertexNormal;
    NSMutableArray *_faces;
    NSMutableArray *_TexCoords;
}

- (GLfloat*) customStringFromFile : (NSString*) name : (NSString*) type;

@end


#endif /* OBJImporter_h */
