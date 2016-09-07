/*
 *  Rover.h
 *  RoverSimulator20120621
 *
 *  Created by Toshihiro Harada on 12/06/27.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#import "MyVector3D.h"
#import "MyQuaternion.h"

#import <stdlib.h>
#import <stdio.h>
class Rover{
	
public:
	double cx;
	double cy;
	double cz;
	double rsize;
	double rmass;
	double **b_point;
	double **preb_point;
	double **original_rover;
	
	double rt[3][3];
	
	int **b_index;
	MyVector3D rNVec; // rover Normal Vector
	MyVector3D rDVec; // rover Direction Vector
	MyVector3D n; // axis of rotation
	MyVector3D b_vec; // box vector
	MyVector3D rtX; 
	MyVector3D rtY;
	MyVector3D rtZ;
	MyVector3D I;
	MyVector3D Iinv;
	
	Rover(void);
	Rover(double,double,double,double,double);//幅、重心のｘ、ｙ、ｚ、質量
	void setAttiRover(MyVector3D, MyVector3D, MyVector3D, double);
	void moveRover(double, double, double);
	void rotateRover(double);
	void rotateRover_axis(double, MyVector3D);
	void rotateRover_vector(MyVector3D,double);
	void setPreRoverPosition();
	
	void transformQuaternionToRotMat(MyVector3D&, MyVector3D&, MyVector3D&, MyQuaternion);
	MyQuaternion transformRotMatToQuaternion(MyVector3D, MyVector3D, MyVector3D);
	
};