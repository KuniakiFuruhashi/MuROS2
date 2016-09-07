/*
 *  CollisionMethod.h
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/06/05.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
#include<vector>
#import "CalLib.h"
#import "Rover.h"
using namespace std;
class CollisionMethod
{
	
public:
	vector<int> *ppp;
	vector<int> *ppm;
	vector<int> *pmp;
	vector<int> *mpp;
	vector<int> *pmm;
	vector<int> *mpm;
	vector<int> *mmp;
	vector<int> *mmm;
	
	CollisionMethod(void);
	CollisionMethod(vector<int>*,vector<int>*,vector<int>*,vector<int>*,vector<int>*,vector<int>*,vector<int>*,vector<int>*);
	void setArea(vector<int>*,vector<int>*,vector<int>*,vector<int>*,vector<int>*,vector<int>*,vector<int>*,vector<int>*);
	int collisionDetect(Rover*, MyVector3D*, MyVector3D, MyVector3D*, MyVector3D, int**,double**,int,double);
	int getNearPolygon(MyVector3D, double**, int**, int);
};