/*
 *  MyVector3D.h
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/05/29.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
extern "C" {
#include<math.h>
}
class MyVector3D{

public:
	double x;
	double y;
	double z;
	
	MyVector3D(void);
	MyVector3D(double,double,double);
	
	void setParameter(double,double,double);
	double length(void);
	void normalize(void);
	double dot(MyVector3D);
	void cross(MyVector3D,MyVector3D);
	MyVector3D rotate(MyVector3D,MyVector3D,double);
	double angleOfVector(MyVector3D);
};


