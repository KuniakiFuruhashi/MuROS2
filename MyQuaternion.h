/*
 *  MyQuaternion.h
 *  ExampleSpace3D
 *
 *  Created by Toshihiro Harada on 12/11/06.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#include <math.h>
#import "MyVector3D.h"
//クォータニオンを扱うクラス
class MyQuaternion{
	
public:
	double x;
	double y;
	double z;
	double w;
	
	MyQuaternion(void);
	MyQuaternion(double,double,double,double);
	void setParameter(double,double,double,double);
	
	void plus(MyQuaternion,MyQuaternion);
	void multi(MyQuaternion,MyQuaternion);
	double length(void);
	void normalize(void);
	
};