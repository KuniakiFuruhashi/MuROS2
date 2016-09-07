/*
 *  MyVector3D.cpp
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/05/29.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "MyVector3D.h"

MyVector3D::MyVector3D(void){ x = y = z = 0;}
MyVector3D::MyVector3D(double x, double y, double z){
	this->x = x; this->y = y; this->z = z;
}

void MyVector3D::setParameter(double tx, double ty, double tz)
{
	this->x = tx;
	this->y = ty;
	this->z = tz;
}

double MyVector3D::length(void){
	return sqrt(x*x+y*y+z*z);
//	return pow(x*x+y*y+z*z, 0.5);
}

void MyVector3D::normalize(void){
	double px,py,pz;
	px = x/sqrt(x*x+y*y+z*z);
	py = y/sqrt(x*x+y*y+z*z);
	pz = z/sqrt(x*x+y*y+z*z);
	
	this->x = px;
	this->y = py;
	this->z = pz;
}

double MyVector3D::dot(MyVector3D v){
	
	return x*v.x+y*v.y+z*v.z;
}

void MyVector3D::cross(MyVector3D u,MyVector3D v){
	this->x = u.y * v.z - u.z * v.y;
	this->y = u.z * v.x - u.x * v.z;
	this->z = u.x * v.y - u.y * v.x;
}


//nを軸にしてvをtheta（ラジアン）だけ回転
MyVector3D MyVector3D::rotate(MyVector3D n,MyVector3D v,double theta){

	MyVector3D vd;
	
	vd.x = v.x*(n.x*n.x*(1-cos(theta))+cos(theta))
	+v.y*(n.x*n.y*(1-cos(theta))+n.z*sin(theta))
	+v.z*(n.x*n.z*(1-cos(theta))-n.y*sin(theta));
	
	vd.y = v.x*(n.x*n.y*(1-cos(theta))-n.z*sin(theta))
	+v.y*(n.y*n.y*(1-cos(theta))+cos(theta))
	+v.z*(n.y*n.z*(1-cos(theta))+n.x*sin(theta));
	
	vd.z = v.x*(n.x*n.z*(1-cos(theta))+n.y*sin(theta))
	+v.y*(n.y*n.z*(1-cos(theta))-n.x*sin(theta))
	+v.z*(n.z*n.z*(1-cos(theta))+cos(theta));
	
	return vd;	
}

//radian
double MyVector3D::angleOfVector(MyVector3D vec) 
{
	return acos(dot(vec)/(length()*vec.length()));
}
