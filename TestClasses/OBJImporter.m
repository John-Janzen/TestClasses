//
//  OBJImporter.m
//  DownTheAbyss
//
//  Created by John Janzen on 2017-03-25.
//  Copyright © 2017 JRCT. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "OBJImporter.h"

@implementation OBJImporter

- (GLfloat*) customStringFromFile : (NSString*) name : (NSString*) type
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSString *StringContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lines = [StringContent componentsSeparatedByString:@"\n"];
    
    NSArray<NSString*> *RowToColumn;
    NSString *Deletespace;
    
    _Vertex = [[NSMutableArray alloc] init];
    _VertexNormal = [[NSMutableArray alloc] init];
    _TexCoords = [[NSMutableArray alloc] init];
    _faces = [[NSMutableArray alloc] init];
    
    for (NSString * line in lines)
    {
        if ([line hasPrefix:@"v "])
        {
            Deletespace = [line substringFromIndex:2];
            RowToColumn = [Deletespace componentsSeparatedByString:@" "];
            
            for (NSString * number in RowToColumn)
            {
                [_Vertex addObject:[NSNumber numberWithFloat:[number floatValue]]];
            }
        }
        else if([line hasPrefix:@"vn "])
        {
            Deletespace = [line substringFromIndex:3];
            RowToColumn = [Deletespace componentsSeparatedByString:@" "];
            
            for (NSString * number in RowToColumn)
            {
                [_VertexNormal addObject:[NSNumber numberWithFloat:[number floatValue]]];
            }
            
        } else if ([line hasPrefix:@"vt "]) {
            
            Deletespace = [line substringFromIndex:3];
            RowToColumn = [Deletespace componentsSeparatedByString:@" "];
            
            for (NSString * number in RowToColumn)
            {
                [_TexCoords addObject:[NSNumber numberWithFloat:[number floatValue]]];
            }
            
            
        } else if([line hasPrefix:@"f "])
            
        {
            Deletespace = [line substringFromIndex:2];
            RowToColumn = [Deletespace componentsSeparatedByString:@" "];
            
            for (NSString * number in RowToColumn)
            {
                NSArray<NSString*> *individualNumbers = [number componentsSeparatedByString:@"/"];
                NSMutableArray *facePointNumbers = [[NSMutableArray alloc] init];
                for (NSString *individualNumber in individualNumbers)
                {
                    [facePointNumbers addObject:[NSNumber numberWithInteger:[individualNumber intValue]]];
                }
                [_faces addObject:facePointNumbers];
            }
            
        }
    }
    
    GLfloat *enemyStuff = (GLfloat*) malloc(sizeof(GLfloat) * (_faces.count * 10));
    for (int i = 0, j = 0; j < _faces.count; i+=10, j++) {
        enemyStuff[i] = [_Vertex[(([_faces[j][0] intValue] - 1) * 3)] floatValue];
        enemyStuff[i + 1] = [_Vertex[(([_faces[j][0] intValue] - 1) * 3) + 1] floatValue];
        enemyStuff[i + 2] = [_Vertex[(([_faces[j][0] intValue] - 1) * 3) + 2] floatValue];
        enemyStuff[i + 3] = 1.0f;
        
        enemyStuff[i + 4] = [_VertexNormal[(([_faces[j][2] intValue] - 1) * 3)] floatValue];
        enemyStuff[i + 5] = [_VertexNormal[(([_faces[j][2] intValue] - 1) * 3) + 1] floatValue];
        enemyStuff[i + 6] = [_VertexNormal[(([_faces[j][2] intValue] - 1) * 3) + 2] floatValue];
        enemyStuff[i + 7] = 1.0f;
        
        enemyStuff[i + 8] = [_TexCoords[(([_faces[j][1] intValue] - 1) * 2)] floatValue];
        enemyStuff[i + 9] = [_TexCoords[(([_faces[j][1] intValue] - 1) * 2) + 1] floatValue];
    }
    return enemyStuff;
}

@end
