/*
 *  CalLib.h
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/06/05.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#import "MyVector3D.h"

class CalLib
{

public:
	
	MyVector3D getGravityCenter(int,double **,int **);
	MyVector3D getNormalVector(int,double **,int **);

};