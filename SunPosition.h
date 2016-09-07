/*
 *  SunPosition.h
 *  RoverSimulator_20120123
 *
 *  Created by Toshihiro Harada on 13/01/23.
 *  Copyright 2013 __MyCompanyName__. All rights reserved.
 *
 */

extern "C" {
#import "SpiceUsr.h"
#include "SpiceDLA.h"
#include "SpiceDSK.h"
#include "dsk_proto.h"
//#include "f2c_proto.h"
}
#define STRLEN 100
#define  BCVLEN 5       //max number of FOV bound vectors
#define  DISTANCE 100
#define  SOLAR_DISTANCE 100
#define  ROOM 10  //add point
#define  PBUFSIZ 50000
#include <string>
//vector.h included by xcode4
#include <vector>
#import <math.h>
using namespace std;

class SunPosition{

public:
	// general purpose variables
		
	double hapke_sum;
	
	SpiceDouble SC_pos_bd[3];
		
	SpiceInt         instid; //instrument NAIF ID Ç∆ÇËÇ†Ç¶Ç∏AMICA ideal
	SpiceBoolean     sc_mode; //FALSE: Psuedo Parallel (LAT/LON), TRUE: refer Spk
	SpiceBoolean     sun_mode; //FALSE: LAT/LON, TRUE: refer Spk
	
	SpiceInt count;
	
	SpiceDouble             et;
	SpiceDouble             start_et;
	SpiceChar               utc[STRLEN];
	
	SpiceDouble             lt_SC;
	string* kernelList;
	int kernelnumber;
	
	
	SunPosition(void);
	SunPosition(vector<string>&, int, string);
	double* getSunPosition(double);
};