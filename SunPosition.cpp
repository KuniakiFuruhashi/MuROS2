/*
 *  SunPosition.cpp
 *  RoverSimulator_20120123
 *
 *  Created by Toshihiro Harada on 13/01/23.
 *  Copyright 2013 __MyCompanyName__. All rights reserved.
 *
 */

#include "SunPosition.h"

SunPosition::SunPosition(void){
	//instid = -130903;
	hapke_sum = 0;
}

SunPosition::SunPosition(vector<string> &spiceFile, int nfile, string startTime){
	kernelList = new string[nfile];
	int i;
	for (i = 0 ;  i < nfile; i++) {
		kernelList[i] = spiceFile[i];
	}
	kernelnumber = nfile;
	
	//instid = -130903;
	hapke_sum = 0;
	
	
	//開始時間の設定
	printf("%s is loaded.\n",kernelList[0].c_str());
	
	for (i = 0; i < kernelnumber; i++) {
		printf("%s is loaded.\n",kernelList[i].c_str());
		
		furnsh_c(kernelList[i].c_str());
		
	}
	
	
	//内部的にはETを用いるので，UTCの開始時間をETに変換
	str2et_c ( startTime.c_str(), &start_et );
	
	//時間etをUTCに変換し，表示
    et2utc_c ( start_et, "ISOC", 0, STRLEN, utc );
    printf("%s\t",utc);
    
	//イトカワ
    spkpos_c ( "SUN", start_et,   "ITOKAWA_FIXED",  "LT+S", "ITOKAWA", SC_pos_bd,  &lt_SC);
 //spkpos_c ( "ITOKAWA", start_et,   "ITOKAWA_FIXED",  "LT+S", "SUN", SC_pos_bd,  &lt_SC);
	//vminus_c (SC_pos_bd,SC_pos_bd);
	
}

double* SunPosition::getSunPosition(double deltaTime){
	et = start_et + deltaTime;
	spkpos_c ( "SUN", et,   "ITOKAWA_FIXED",  "LT+S", "ITOKAWA", SC_pos_bd,  &lt_SC);
	
	return SC_pos_bd;
}