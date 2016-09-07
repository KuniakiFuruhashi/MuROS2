//
//  CalcTrajectory.h
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/05/19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "MyVector3D.h"

//#import "MyVector.h"
#import "GravitationCalculator.h"
#import "CollisionMethod.h"
#import "RayTrace.h"
#import "Rover.h"
#import "SunPosition.h"
#include <vector>
#include <string>
#import <stdlib.h>
using namespace std;


@interface CalcTrajectory : NSObject {
	//MyVector *rover_v;
	double vx,vy,vz;
	CollisionMethod clmth;
	vector<int>* ppp;
	vector<int>* ppm;
	vector<int>* pmp;
	vector<int>* mpp;
	vector<int>* pmm;
	vector<int>* mpm;
	vector<int>* mmp;
	vector<int>* mmm;
	NSString *currentPath;
	Rover minerva;
}

@property vector<int> *ppp,*ppm,*pmp,*mpp,*pmm,*mpm,*mmp,*mmm;
//Method of Caluculation
-(void)vp:(MyVector3D)vp normalVec:(MyVector3D)norm verticesData:(double**)vData plateData:(int**)pData commonFData:(int**)commonF numberOfvertices:(int)nv numberOfplate:(int)np InitPX:(double)Initpx InitPY:(double)Initpy InitPZ:(double)Initpz InitVX:(double)Initvx InitVY:(double)Initvy InitVZ:(double)Initvz fai:(double)fai theta:(double)theta rotationAV:(double)w density:(double)density stepsize:(double)h limit:(double)limit e:(double)e dskfile:(string)dskfile rsize:(double)rsize rmass:(double)rmass roverAV:(double)rw rotationAxis:(MyVector3D)rotationAxis;
//what is this Caluculation?
-(void)vp:(MyVector3D)vp normalVec:(MyVector3D)norm verticesData:(double**)vData plateData:(int**)pData commonFData:(int**)commonF numberOfvertices:(int)nv numberOfplate:(int)np InitPX:(double)Initpx InitPY:(double)Initpy InitPZ:(double)Initpz InitVX:(double)Initvx InitVY:(double)Initvy InitVZ:(double)Initvz fai:(double)fai theta:(double)theta rotationAV:(double)w density:(double)density stepsize:(double)h limit:(double)limit e:(double)e dskfile:(string)dskfile rsize:(double)rsize rmass:(double)rmass roverAV:(double)rw rotationAxis:(MyVector3D)rotationAxis sunPosition:(SunPosition)sunP;

-(double)fo_x:(double)x fo_y:(double)y fo_z:(double)z fo_o:(double)o fo_p:(double)p fo_q:(double)q fo_t:(double)t fo_w:(double)w fo_gx:(double)gx;
-(double)fp_x:(double)x fp_y:(double)y fp_z:(double)z fp_o:(double)o fp_p:(double)p fp_q:(double)q fp_t:(double)t fp_w:(double)w fp_gy:(double)gy;
-(double)fq_x:(double)x fq_y:(double)y fq_z:(double)z fq_o:(double)o fq_p:(double)p fq_q:(double)q fq_t:(double)t fq_w:(double)w fq_gz:(double)gz;
-(double)fx_t:(double)t fx_o:(double)o;
-(double)fy_t:(double)t fy_p:(double)p;
-(double)fz_t:(double)t fz_q:(double)q;
-(void)setAreaGroup:(vector<int>*)tppp ppm:(vector<int>*)tppm pmp:(vector<int>*)tpmp mpp:(vector<int>*)tmpp pmm:(vector<int>*)tpmm mpm:(vector<int>*)tmpm mmp:(vector<int>*)tmmp mmm:(vector<int>*)tmmm;
-(double)toDegrees:(double)radian;
-(double)toRadian:(double)degrees;


@end
