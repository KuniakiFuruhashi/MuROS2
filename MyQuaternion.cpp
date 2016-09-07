/*
 *  MyQuaternion.cpp
 *  ExampleSpace3D
 *
 *  Created by Toshihiro Harada on 12/11/06.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "MyQuaternion.h"

MyQuaternion::MyQuaternion(void){ x = y = z = w = 0;}
MyQuaternion::MyQuaternion(double x, double y, double z, double w){
	this->x = x;
	this->y = y;
	this->z = z;
	this->w = w;
}
void MyQuaternion::setParameter(double x, double y, double z, double w)
{
	this->x = x;
	this->y = y;
	this->z = z;
	this->w = w;
}
void MyQuaternion::plus(MyQuaternion p,MyQuaternion q)
{
	this->x = p.x + q.x;
	this->y = p.y + q.y;
	this->z = p.z + q.z;
	this->w = p.w + q.w;
}
void MyQuaternion::multi(MyQuaternion p,MyQuaternion q)
{
	MyVector3D v1(p.x,p.y,p.z);
	MyVector3D v2(q.x,q.y,q.z);
	MyVector3D  cross;
	cross.cross(v1, v2);
	
	this->x = cross.x+p.w*v2.x+q.w*v1.x;
	this->y = cross.y+p.w*v2.y+q.w*v1.y;
	this->z = cross.z+p.w*v2.z+q.w*v1.z;
	this->w = p.w*q.w-v1.dot(v2);
	/*
	this->x = p.w*q.w - p.x*q.x - p.y*q.y - p.x*q.z;
	this->y = p.w*q.x + p.x*q.w + p.y*q.z - p.z*q.y;
	this->z = p.w*q.y - p.x*q.z + p.y*q.w + p.z*q.x;
	this->w = p.w*q.z + p.x*q.y - p.y*q.x + p.x*q.w;
	 */
}
double MyQuaternion::length(void)
{
	return sqrt(this->x*this->x + this->y*this->y + this->z*this->z + this->w*this->w);
}
void MyQuaternion::normalize(void)
{
	this->x = this->x/length();
	this->y = this->y/length();
	this->z = this->z/length();
	this->w = this->w/length();

}