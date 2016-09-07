/*
 *  GravitationCalculator.h
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/05/29.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#import "MyVector3D.h"

#include <stdio.h>
#include <stdlib.h>
class GravitationCalculator{

public:
	double u;
	double laplas;

	GravitationCalculator(void);
	double getlaplas(void);
	MyVector3D calculateG(MyVector3D,double**,int**,int**,int,int,double);
	MyVector3D getPosition(int,double**,int**);
	MyVector3D getNormal(int,double**,int**);
	void dyad(double**,MyVector3D,MyVector3D);
	

};

