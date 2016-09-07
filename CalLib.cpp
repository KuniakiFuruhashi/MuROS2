/*
 *  CalLib.cpp
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/06/05.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "CalLib.h"

MyVector3D CalLib::getGravityCenter(int pID, double** data ,int** platedata)
{
	MyVector3D p0(data[platedata[pID][0]-1][0],data[platedata[pID][0]-1][1],data[platedata[pID][0]-1][2]);
	MyVector3D p1(data[platedata[pID][1]-1][0],data[platedata[pID][1]-1][1],data[platedata[pID][1]-1][2]);
	MyVector3D p2(data[platedata[pID][2]-1][0],data[platedata[pID][2]-1][1],data[platedata[pID][2]-1][2]);
	
	MyVector3D re((p0.x + p1.x + p2.x)/3.0,(p0.y + p1.y + p2.y)/3.0,(p0.z + p1.z + p2.z)/3.0);
	
	return re;
}

MyVector3D CalLib::getNormalVector(int pID,double** data, int** platedata)
{
	MyVector3D p0(data[platedata[pID][0]-1][0],data[platedata[pID][0]-1][1],data[platedata[pID][0]-1][2]);
	MyVector3D p1(data[platedata[pID][1]-1][0],data[platedata[pID][1]-1][1],data[platedata[pID][1]-1][2]);
	MyVector3D p2(data[platedata[pID][2]-1][0],data[platedata[pID][2]-1][1],data[platedata[pID][2]-1][2]);
	
	MyVector3D v1(p1.x - p0.x, p1.y - p0.y, p1.z - p0.z);
	MyVector3D v2(p2.x - p0.x, p2.y - p0.y, p2.z - p0.z);
	
	MyVector3D normal;
	normal.cross(v1, v2);
	normal.normalize();
	
	return normal;
}

