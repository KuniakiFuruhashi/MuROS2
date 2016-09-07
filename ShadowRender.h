/*
 *  ShadowRender.h
 *  RoverSimulator_20121119
 *
 *  Created by Toshihiro Harada on 12/12/08.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
extern "C" {
#import "SpiceUsr.h"
#include "SpiceDLA.h"
#include "SpiceDSK.h"
#include "pl02.h"
#include "dsk_proto.h"
#include "f2c_proto.h"
}
#define STRLEN 100
#define  BCVLEN 5       //max number of FOV bound vectors
#define  DISTANCE 100
#define  SOLAR_DISTANCE 100
#define  ROOM 10  //add point
#define  PBUFSIZ 50000
#include <string>
#import <math.h>
using namespace std;
class ShadowRender{
	
public:
	// general purpose variables
	SpiceChar   instr[STRLEN];
	SpiceDouble    pixel_dbl[2];
	SpiceDouble    image_size[2];
	SpiceDouble    image_center[2];
	SpiceInt    address;
	SpiceBoolean found, lightened;
	SpiceInt         n_return;  //add point
	
	
	SpiceDouble incidence,emission;
	SpiceDouble phase,range,radius;
	SpiceDouble lat,lon;
	
	double hapke_sum;
	
	SpiceDouble SC_pos_bd[3],solar_pos_bd[3],SC_pos_bdm[3];
	SpiceDouble SC_pos_hp[3];
	SpiceDouble SC_pos_bd_d[3],solar_pos_bd_d[3],earth_pos_bd_d[3];
	SpiceDouble solar_pos_bd_d_i[3];
	SpiceDouble rotate_x,rotate_y,rotate_z;
	SpiceDouble SC_lat,SC_lon;
	SpiceDouble solar_lat,solar_lon;
	SpiceDouble lt;
	
	SpiceInt         instid; //instrument NAIF ID Ç∆ÇËÇ†Ç¶Ç∏AMICA ideal
	SpiceBoolean     sc_mode; //FALSE: Psuedo Parallel (LAT/LON), TRUE: refer Spk
	SpiceBoolean     sun_mode; //FALSE: LAT/LON, TRUE: refer Spk
	
	//getfov_c releted variables
	SpiceChar        shape  [STRLEN];
	SpiceChar        frame  [STRLEN]; //name of frame that FOV/boresight are defined.
	SpiceDouble      bsight [3]; //boresight vector
	SpiceInt         n_bcv; //number of FOV bound vectors
	SpiceDouble      bounds [BCVLEN][3];
	
	SpiceDouble      bsight_bd [3]; //boresight vector
	
	SpiceDouble rotate[3][3];
	SpiceDouble rotate_inv[3][3];
	SpiceDouble rotate_cam[3][3];
	
	SpiceDouble plnorm[3];
	SpiceInt    PLID;
	SpiceInt    PLDEX;
	SpiceInt    BODY;
	SpiceInt    BODIDX;
	SpiceDouble albedo;
	SpiceDouble surface_point[3];
	SpiceDouble surface_point_tmp[3];
	SpiceDouble lon2,lat2,distan;
	
	SpicePlane image_plane;
	SpiceDouble origin[3];
	SpiceInt                handle;
	SpiceDLADescr dladsc;
	//SpiceChar               dsk[256];
	SpiceInt nv;
	SpiceInt np;
	SpiceInt remain;
	SpiceInt nread;
	SpiceInt plates[PBUFSIZ][3];
	SpiceInt i;
	SpiceInt j;
	SpiceInt k;
	SpiceInt n;
	SpiceInt plix;
	SpiceInt nvtx;
	SpiceInt start;
	SpiceDouble gx;
	SpiceDouble gy;
	SpiceDouble gz;
	SpiceDouble verts [3][3];
	SpiceInt count;
	
	SpiceDouble             et;
	SpiceDouble             start_et;
	SpiceChar               utc[STRLEN];
	
	SpiceDouble             lunar_pos_bd[3];
	SpiceDouble             SC_pos_J2k[3];
	SpiceDouble             lunar_pos_J2k[3];
	SpiceDouble             lt_SC, lt_lunar;
	string* kernelList;
	int kernelnumber;
	
	
	ShadowRender(void);
	ShadowRender(string[], int);
	double** getShadow(string,double);
	double* getSunPosition(void);
};

