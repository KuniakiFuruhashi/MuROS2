/*
 *  CollisionMethod.cpp
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/06/05.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "CollisionMethod.h"

CollisionMethod::CollisionMethod(void){

}

CollisionMethod::CollisionMethod(vector<int> *tppp,vector<int> *tppm,vector<int> *tpmp,vector<int> *tmpp,vector<int> *tpmm,vector<int> *tmpm,vector<int> *tmmp,vector<int> *tmmm)
{
	ppp = tppp;
	ppm = tppm;
	pmp = tpmp;
	mpp = tmpp;
	pmm = tpmm;
	mpm = tmpm;
	mmp = tmmp;
	mmm = tmmm;
}

void CollisionMethod::setArea(vector<int> *tppp,vector<int> *tppm,vector<int> *tpmp,vector<int> *tmpp,vector<int> *tpmm,vector<int> *tmpm,vector<int> *tmmp,vector<int> *tmmm)
{
	ppp = tppp;
	ppm = tppm;
	pmp = tpmp;
	mpp = tmpp;
	pmm = tpmm;
	mpm = tmpm;
	mmp = tmmp;
	mmm = tmmm;
	
}

int CollisionMethod::collisionDetect(Rover *minerva, MyVector3D *rover, MyVector3D preRover, MyVector3D *v, MyVector3D pre_v, int** platedata, double** data, int np, double e)
{
	
	CalLib clb;
	MyVector3D pNormal;
	MyVector3D pCenter;
	MyVector3D pcVector;
	MyVector3D lenvec;
	MyVector3D ux;
	MyVector3D uy;
	MyVector3D uz;
	//double angle;
	double fieldRadius = 0.02;//km
	double r;
	double s;
	if ((*rover).x >= 0 && (*rover).y >= 0 && (*rover).z >= 0) 
	{
		printf("ppp in for loop %lf %lf %lf\n",(*rover).x,(*rover).y,(*rover).z);

		for (int i = 0; i < (*ppp).size(); i++) 
		{
			
			pNormal = clb.getNormalVector((*ppp)[i]-1, data, platedata);
            //pCenter.x =0;
            //pCenter.y =0;
            //pCenter.z= 500;
            pCenter = clb.getGravityCenter((*ppp)[i]-1, data, platedata);
			pcVector.x = /*pCenter.x - */(*rover).x - pCenter.x;
			pcVector.y = /*pCenter.y - */(*rover).y - pCenter.y;
			pcVector.z = /*pCenter.z - */(*rover).z - pCenter.z;
			lenvec.setParameter(preRover.x-pCenter.x, preRover.y-pCenter.y, preRover.z-pCenter.z);
			
			if (pcVector.length() < fieldRadius) {
				printf("detect near polygon: %d %d\n",i,(*ppp)[i]);
				ux.setParameter((*minerva).rtX.x*(*minerva).rsize/2, (*minerva).rtX.y*(*minerva).rsize/2, (*minerva).rtX.z*(*minerva).rsize/2.0);
				uy.setParameter((*minerva).rtY.x*(*minerva).rsize/2.0, (*minerva).rtY.y*(*minerva).rsize/2.0, (*minerva).rtY.z*(*minerva).rsize/2.0);
				uz.setParameter((*minerva).rtZ.x*(*minerva).rsize/2.0, (*minerva).rtZ.y*(*minerva).rsize/2.0, (*minerva).rtZ.z*(*minerva).rsize/2.0);
				r = fabs(ux.dot(pNormal)) + fabs(uy.dot(pNormal)) + fabs(uz.dot(pNormal));
				s = fabs(pNormal.dot(MyVector3D((*minerva).cx - pCenter.x, (*minerva).cy - pCenter.y, (*minerva).cz - pCenter.z)));
				
				if (r > s) {
					printf("Collision Detect !! %d %d\n",i,(*ppp)[i]);
					printf("minerva_b: %lf %lf %lf\n",(*minerva).cx,(*minerva).cy,(*minerva).cz);
					(*minerva).moveRover((*minerva).cx+pNormal.x*(r-s), (*minerva).cy + pNormal.y*(r-s), (*minerva).cz + pNormal.z*(r-s));
					return 1;
				}
			}
		}
	}
	
	else if ((*rover).x >= 0 && (*rover).y >= 0 && (*rover).z <= 0) 
	{
		printf("ppm in for loop %lf %lf %lf\n",(*rover).x,(*rover).y,(*rover).z);

		for (int i = 0; i < (*ppm).size(); i++) 
		{
			pNormal = clb.getNormalVector((*ppm)[i]-1, data, platedata);
			pCenter = clb.getGravityCenter((*ppm)[i]-1, data, platedata);
			pcVector.x = /*pCenter.x - */(*rover).x - pCenter.x;
			pcVector.y = /*pCenter.y - */(*rover).y - pCenter.y;
			pcVector.z = /*pCenter.z - */(*rover).z - pCenter.z;
			lenvec.setParameter(preRover.x-pCenter.x, preRover.y-pCenter.y, preRover.z-pCenter.z);

			if (pcVector.length() < fieldRadius) {
				
				printf("detect near polygon: %d %d\n",i,(*ppm)[i]);
				ux.setParameter((*minerva).rtX.x*(*minerva).rsize/2.0, (*minerva).rtX.y*(*minerva).rsize/2.0, (*minerva).rtX.z*(*minerva).rsize/2.0);
				uy.setParameter((*minerva).rtY.x*(*minerva).rsize/2.0, (*minerva).rtY.y*(*minerva).rsize/2.0, (*minerva).rtY.z*(*minerva).rsize/2.0);
				uz.setParameter((*minerva).rtZ.x*(*minerva).rsize/2.0, (*minerva).rtZ.y*(*minerva).rsize/2.0, (*minerva).rtZ.z*(*minerva).rsize/2.0);
				r = fabs(ux.dot(pNormal)) + fabs(uy.dot(pNormal)) + fabs(uz.dot(pNormal));
				s = fabs(pNormal.dot(MyVector3D((*minerva).cx - pCenter.x, (*minerva).cy - pCenter.y, (*minerva).cz - pCenter.z)));
				
				if (r > s) {
					printf("Collision Detect !! %d %d\n",i,(*ppm)[i]);
					printf("minerva_b: %lf %lf %lf\n",(*minerva).cx,(*minerva).cy,(*minerva).cz);
					(*minerva).moveRover((*minerva).cx+pNormal.x*(r-s), (*minerva).cy + pNormal.y*(r-s), (*minerva).cz + pNormal.z*(r-s));
					return 1;
				}
				
			}
		}
	}
	
	else if ((*rover).x >= 0 && (*rover).y <= 0 && (*rover).z >= 0) 
	{
		printf("pmp in for loop %lf %lf %lf\n",(*rover).x,(*rover).y,(*rover).z);

		for (int i = 0; i < (*pmp).size(); i++) 
		{
			pNormal = clb.getNormalVector((*pmp)[i]-1, data, platedata);
			pCenter = clb.getGravityCenter((*pmp)[i]-1, data, platedata);
			pcVector.x = /*pCenter.x - */(*rover).x - pCenter.x;
			pcVector.y = /*pCenter.y - */(*rover).y - pCenter.y;
			pcVector.z = /*pCenter.z - */(*rover).z - pCenter.z;
			lenvec.setParameter(preRover.x-pCenter.x, preRover.y-pCenter.y, preRover.z-pCenter.z);

			if (pcVector.length() < fieldRadius) {
				
				printf("detect near polygon: %d %d\n",i,(*pmp)[i]);
				ux.setParameter((*minerva).rtX.x*(*minerva).rsize/2.0, (*minerva).rtX.y*(*minerva).rsize/2.0, (*minerva).rtX.z*(*minerva).rsize/2.0);
				uy.setParameter((*minerva).rtY.x*(*minerva).rsize/2.0, (*minerva).rtY.y*(*minerva).rsize/2.0, (*minerva).rtY.z*(*minerva).rsize/2.0);
				uz.setParameter((*minerva).rtZ.x*(*minerva).rsize/2.0, (*minerva).rtZ.y*(*minerva).rsize/2.0, (*minerva).rtZ.z*(*minerva).rsize/2.0);
				r = fabs(ux.dot(pNormal)) + fabs(uy.dot(pNormal)) + fabs(uz.dot(pNormal));
				s = fabs(pNormal.dot(MyVector3D((*minerva).cx - pCenter.x, (*minerva).cy - pCenter.y, (*minerva).cz - pCenter.z)));
				
				if (r > s) {
					printf("Collision Detect !! %d %d\n",i,(*pmp)[i]);
					printf("minerva_b: %lf %lf %lf\n",(*minerva).cx,(*minerva).cy,(*minerva).cz);
					(*minerva).moveRover((*minerva).cx+pNormal.x*(r-s), (*minerva).cy + pNormal.y*(r-s), (*minerva).cz + pNormal.z*(r-s));

					return 1;
				}
				
			}
		}
	}
	
	else if ((*rover).x <= 0 && (*rover).y >= 0 && (*rover).z >= 0) 
	{
		printf("mpp in for loop %lf %lf %lf\n",(*rover).x,(*rover).y,(*rover).z);

		for (int i = 0; i < (*mpp).size(); i++) 
		{
			pNormal = clb.getNormalVector((*mpp)[i]-1, data, platedata);
			pCenter = clb.getGravityCenter((*mpp)[i]-1, data, platedata);
			pcVector.x = /*pCenter.x - */(*rover).x - pCenter.x;
			pcVector.y = /*pCenter.y - */(*rover).y - pCenter.y;
			pcVector.z = /*pCenter.z - */(*rover).z - pCenter.z;
			lenvec.setParameter(preRover.x-pCenter.x, preRover.y-pCenter.y, preRover.z-pCenter.z);

			if (pcVector.length() < fieldRadius) {
				
				printf("detect near polygon: %d %d\n",i,(*mpp)[i]);
				ux.setParameter((*minerva).rtX.x*(*minerva).rsize/2.0, (*minerva).rtX.y*(*minerva).rsize/2.0, (*minerva).rtX.z*(*minerva).rsize/2.0);
				uy.setParameter((*minerva).rtY.x*(*minerva).rsize/2.0, (*minerva).rtY.y*(*minerva).rsize/2.0, (*minerva).rtY.z*(*minerva).rsize/2.0);
				uz.setParameter((*minerva).rtZ.x*(*minerva).rsize/2.0, (*minerva).rtZ.y*(*minerva).rsize/2.0, (*minerva).rtZ.z*(*minerva).rsize/2.0);
				r = fabs(ux.dot(pNormal)) + fabs(uy.dot(pNormal)) + fabs(uz.dot(pNormal));
				s = fabs(pNormal.dot(MyVector3D((*minerva).cx - pCenter.x, (*minerva).cy - pCenter.y, (*minerva).cz - pCenter.z)));
				
				if (r > s) {
					printf("Collision Detect !! %d %d\n",i,(*mpp)[i]);
					printf("minerva_b: %lf %lf %lf\n",(*minerva).cx,(*minerva).cy,(*minerva).cz);
					(*minerva).moveRover((*minerva).cx+pNormal.x*(r-s), (*minerva).cy + pNormal.y*(r-s), (*minerva).cz + pNormal.z*(r-s));
					return 1;
				}
				
			}
		}
	}
	
	else if ((*rover).x >= 0 && (*rover).y <= 0 && (*rover).z <= 0) 
	{
		printf("pmm in for loop %lf %lf %lf\n",(*rover).x,(*rover).y,(*rover).z);

		for (int i = 0; i < (*pmm).size(); i++) 
		{
			pNormal = clb.getNormalVector((*pmm)[i]-1, data, platedata);
			pCenter = clb.getGravityCenter((*pmm)[i]-1, data, platedata);
			pcVector.x = /*pCenter.x - */(*rover).x - pCenter.x;
			pcVector.y = /*pCenter.y - */(*rover).y - pCenter.y;
			pcVector.z = /*pCenter.z - */(*rover).z - pCenter.z;
			lenvec.setParameter(preRover.x-pCenter.x, preRover.y-pCenter.y, preRover.z-pCenter.z);

			if (pcVector.length() < fieldRadius) {
				
				printf("detect near polygon: %d %d\n",i,(*pmm)[i]);
				ux.setParameter((*minerva).rtX.x*(*minerva).rsize/2.0, (*minerva).rtX.y*(*minerva).rsize/2.0, (*minerva).rtX.z*(*minerva).rsize/2.0);
				uy.setParameter((*minerva).rtY.x*(*minerva).rsize/2.0, (*minerva).rtY.y*(*minerva).rsize/2.0, (*minerva).rtY.z*(*minerva).rsize/2.0);
				uz.setParameter((*minerva).rtZ.x*(*minerva).rsize/2.0, (*minerva).rtZ.y*(*minerva).rsize/2.0, (*minerva).rtZ.z*(*minerva).rsize/2.0);
				r = fabs(ux.dot(pNormal)) + fabs(uy.dot(pNormal)) + fabs(uz.dot(pNormal));
				s = fabs(pNormal.dot(MyVector3D((*minerva).cx - pCenter.x, (*minerva).cy - pCenter.y, (*minerva).cz - pCenter.z)));
				
				if (r > s) {
					printf("Collision Detect !! %d %d\n",i,(*pmm)[i]);
					printf("minerva_b: %lf %lf %lf\n",(*minerva).cx,(*minerva).cy,(*minerva).cz);
					(*minerva).moveRover((*minerva).cx+pNormal.x*(r-s), (*minerva).cy + pNormal.y*(r-s), (*minerva).cz + pNormal.z*(r-s));
					return 1;	
				}
				
			}
		}
	}
	
	else if ((*rover).x <= 0 && (*rover).y >= 0 && (*rover).z <= 0) 
	{
		printf("mpm in for loop %lf %lf %lf\n",(*rover).x,(*rover).y,(*rover).z);

		for (int i = 0; i < (*mpm).size(); i++) 
		{
			pNormal = clb.getNormalVector((*mpm)[i]-1, data, platedata);
			pCenter = clb.getGravityCenter((*mpm)[i]-1, data, platedata);
			pcVector.x = /*pCenter.x - */(*rover).x - pCenter.x;
			pcVector.y = /*pCenter.y - */(*rover).y - pCenter.y;
			pcVector.z = /*pCenter.z - */(*rover).z - pCenter.z;
			lenvec.setParameter(preRover.x-pCenter.x, preRover.y-pCenter.y, preRover.z-pCenter.z);

			if (pcVector.length() < fieldRadius) {
				
				printf("detect near polygon: %d %d\n",i,(*mpm)[i]);
				ux.setParameter((*minerva).rtX.x*(*minerva).rsize/2.0, (*minerva).rtX.y*(*minerva).rsize/2.0, (*minerva).rtX.z*(*minerva).rsize/2.0);
				uy.setParameter((*minerva).rtY.x*(*minerva).rsize/2.0, (*minerva).rtY.y*(*minerva).rsize/2.0, (*minerva).rtY.z*(*minerva).rsize/2.0);
				uz.setParameter((*minerva).rtZ.x*(*minerva).rsize/2.0, (*minerva).rtZ.y*(*minerva).rsize/2.0, (*minerva).rtZ.z*(*minerva).rsize/2.0);
				r = fabs(ux.dot(pNormal)) + fabs(uy.dot(pNormal)) + fabs(uz.dot(pNormal));
				s = fabs(pNormal.dot(MyVector3D((*minerva).cx - pCenter.x, (*minerva).cy - pCenter.y, (*minerva).cz - pCenter.z)));
				
				if (r > s) {
					printf("Collision Detect !! %d %d\n",i,(*mpm)[i]);
					printf("minerva_b: %lf %lf %lf\n",(*minerva).cx,(*minerva).cy,(*minerva).cz);
					(*minerva).moveRover((*minerva).cx+pNormal.x*(r-s), (*minerva).cy + pNormal.y*(r-s), (*minerva).cz + pNormal.z*(r-s));
					return 1;
				}
				
			}
		}
	}
	
	else if ((*rover).x <= 0 && (*rover).y <= 0 && (*rover).z >= 0) 
	{
		printf("mmp in for loop %lf %lf %lf\n",(*rover).x,(*rover).y,(*rover).z);

		for (int i = 0; i < (*mmp).size(); i++) 
		{
			pNormal = clb.getNormalVector((*mmp)[i]-1, data, platedata);
			pCenter = clb.getGravityCenter((*mmp)[i]-1, data, platedata);
			pcVector.x = /*pCenter.x - */(*rover).x - pCenter.x;
			pcVector.y = /*pCenter.y - */(*rover).y - pCenter.y;
			pcVector.z = /*pCenter.z - */(*rover).z - pCenter.z;
			lenvec.setParameter(preRover.x-(*rover).x, preRover.y-(*rover).y, preRover.z-(*rover).z);

			if (pcVector.length() < fieldRadius) {
				
				printf("detect near polygon: %d %d\n",i,(*mmp)[i]);
				ux.setParameter((*minerva).rtX.x*(*minerva).rsize/2.0, (*minerva).rtX.y*(*minerva).rsize/2.0, (*minerva).rtX.z*(*minerva).rsize/2.0);
				uy.setParameter((*minerva).rtY.x*(*minerva).rsize/2.0, (*minerva).rtY.y*(*minerva).rsize/2.0, (*minerva).rtY.z*(*minerva).rsize/2.0);
				uz.setParameter((*minerva).rtZ.x*(*minerva).rsize/2.0, (*minerva).rtZ.y*(*minerva).rsize/2.0, (*minerva).rtZ.z*(*minerva).rsize/2.0);
				r = fabs(ux.dot(pNormal)) + fabs(uy.dot(pNormal)) + fabs(uz.dot(pNormal));
				s = fabs(pNormal.dot(MyVector3D((*minerva).cx - pCenter.x, (*minerva).cy - pCenter.y, (*minerva).cz - pCenter.z)));
				
				if (r > s) {
					printf("Collision Detect !! %d %d\n",i,(*mmp)[i]);
					printf("minerva_b: %lf %lf %lf\n",(*minerva).cx,(*minerva).cy,(*minerva).cz);
					(*minerva).moveRover((*minerva).cx+pNormal.x*(r-s), (*minerva).cy + pNormal.y*(r-s), (*minerva).cz + pNormal.z*(r-s));
					printf("r-s:%lf %lf %lf\n",r-s,r,s);
					return 1;
				}
				
			}
		}
	}
	
	else if ((*rover).x <= 0 && (*rover).y <= 0 && (*rover).z <= 0) 
	{
		printf("mmm in for loop %lf %lf %lf\n",(*rover).x,(*rover).y,(*rover).z);

		for (int i = 0; i < (*mmm).size(); i++) 
		{
			pNormal = clb.getNormalVector((*mmm)[i]-1, data, platedata);
			pCenter = clb.getGravityCenter((*mmm)[i]-1, data, platedata);
			pcVector.x = /*pCenter.x - */(*rover).x - pCenter.x;
			pcVector.y = /*pCenter.y - */(*rover).y - pCenter.y;
			pcVector.z = /*pCenter.z - */(*rover).z - pCenter.z;
			lenvec.setParameter(preRover.x-pCenter.x, preRover.y-pCenter.y, preRover.z-pCenter.z);

			if (pcVector.length() < fieldRadius) {
				
				printf("detect near polygon: %d %d\n",i,(*mmm)[i]);
				ux.setParameter((*minerva).rtX.x*(*minerva).rsize/2.0, (*minerva).rtX.y*(*minerva).rsize/2.0, (*minerva).rtX.z*(*minerva).rsize/2.0);
				uy.setParameter((*minerva).rtY.x*(*minerva).rsize/2.0, (*minerva).rtY.y*(*minerva).rsize/2.0, (*minerva).rtY.z*(*minerva).rsize/2.0);
				uz.setParameter((*minerva).rtZ.x*(*minerva).rsize/2.0, (*minerva).rtZ.y*(*minerva).rsize/2.0, (*minerva).rtZ.z*(*minerva).rsize/2.0);
				r = fabs(ux.dot(pNormal)) + fabs(uy.dot(pNormal)) + fabs(uz.dot(pNormal));
				s = fabs(pNormal.dot(MyVector3D((*minerva).cx - pCenter.x, (*minerva).cy - pCenter.y, (*minerva).cz - pCenter.z)));
				
				if (r > s) {
					printf("Collision Detect !! %d %d\n",i,(*mmm)[i]);
					printf("minerva_b: %lf %lf %lf\n",(*minerva).cx,(*minerva).cy,(*minerva).cz);
					(*minerva).moveRover((*minerva).cx+pNormal.x*(r-s), (*minerva).cy + pNormal.y*(r-s), (*minerva).cz + pNormal.z*(r-s));
					return 1;
				}
				
			}
		}
	}
	return 0;
}

int CollisionMethod::getNearPolygon(MyVector3D now_position, double** data, int** platedata, int np)
{
	int min_id = 0;
	CalLib clb;
	double min = now_position.length();
	for (int i = 0 ; i < np ; i++ ) {
		MyVector3D l(now_position.x - clb.getGravityCenter(i, data, platedata).x,
					 now_position.y - clb.getGravityCenter(i, data, platedata).y,
					 now_position.z - clb.getGravityCenter(i, data, platedata).z);
		
		if( min > l.length())
		{
			min = l.length();
			min_id = i;
		}
	}
	
	return min_id+1;
}
