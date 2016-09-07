/*
 *  ShadowRender.cpp
 *  RoverSimulator_20121119
 *
 *  Created by Toshihiro Harada on 12/12/08.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "ShadowRender.h"

ShadowRender::ShadowRender(void){
	instid = -130903;
	hapke_sum = 0;
}

ShadowRender::ShadowRender(string spiceFile[], int nfile){
	kernelList = new string[nfile];
	for (int i = 0 ;  i < nfile; i++) {
		kernelList[i] = spiceFile[i];
	}
	kernelnumber = nfile;
	
	instid = -130903;
	hapke_sum = 0;
}
double** ShadowRender::getShadow(string dskfile,double dh){
	
	//開始時間の設定
	printf("%s is loaded.\n",kernelList[0].c_str());

	SpiceChar   time[STRLEN]="2004-05-17T00:00:00";
	
	double** plateCdata;
	
	//使用するkernelの読み込み（ti2utcとは流儀が違うが，どちらでもよい）
	printf("%s is loaded.\n",kernelList[0].c_str());

	for (i = 0; i < kernelnumber; i++) {
		printf("%s is loaded.\n",kernelList[i].c_str());

		furnsh_c(kernelList[i].c_str());
		printf("%s is loaded.\n",kernelList[i].c_str());

	}
	
	
	//内部的にはETを用いるので，UTCの開始時間をETに変換
	str2et_c ( time, &start_et );
	
	//時間etをUTCに変換し，表示
    et2utc_c ( start_et, "ISOC", 0, STRLEN, utc );
    printf("%s\t",utc);
    
	start_et += dh;
	//イトカワ
    spkpos_c ( "SUN", start_et,   "ITOKAWA_FIXED",  "LT+S", "ITOKAWA", SC_pos_bd,  &lt_SC);
	
	
	solar_pos_bd[0] = SC_pos_bd[0];
	solar_pos_bd[1] = SC_pos_bd[1];
	solar_pos_bd[2] = SC_pos_bd[2];
	///DSK file ?
	///Open DSK file
	dasopr_c( dskfile.c_str(), &handle );
	/*
	 Begin a forward search through the
	 kernel, treating the file as a DLA.
	 In this example, it's a very short
	 search.
	 */
	//serch the kernel in the DSK file.
	//If not find DSK file, found is 0.
	dlabfs_c ( handle, &dladsc, &found );
	
	if ( !found  )
	{
		/*
		 We arrive here only if the kernel
		 contains no segments.  This is
		 unexpected, but we're prepared for it.
		 */
		setmsg_c ( "No segments found in DSK file #.");
		sigerr_c ( "SPICE(NODATA)"                   );
	}
	
	dskz02_c(handle, &dladsc, &nv, &np );
	remain = np;
	start = 1;
	
	//plateCdataを初期化 値は0.01に
	plateCdata = new double*[np];
	plateCdata[0] = new double[np * 3];
	for (i = 1; i < np; i++) plateCdata[i] = plateCdata[0] + i * 3;
	
	while ( remain > 0 ){
		nread = mini_c(2,PBUFSIZ, remain);
		dskp02_c(handle, &dladsc, start, nread, &n, plates );
		
		for( i = 0 ; i < nread ; i++ ){
			plix = start + i;
			
			for( j = 0 ; j < 3 ; j++){
				dskv02_c(handle, &dladsc, plates[i][j],
						 1, &nvtx,
						 (SpiceDouble(*)[3])(verts[j]) );
			}
			
			gx = (verts[0][0]+verts[1][0]+verts[2][0])/3;
			gy = (verts[0][1]+verts[1][1]+verts[2][1])/3;
			gz = (verts[0][2]+verts[1][2]+verts[2][2])/3;
			surface_point[0] = gx;
			surface_point[1] = gy;
			surface_point[2] = gz;
			vsub_c(solar_pos_bd,surface_point,solar_pos_bd_d);
			vminus_c(solar_pos_bd_d,solar_pos_bd_d_i);
			dskx02_c(handle, &dladsc, solar_pos_bd, solar_pos_bd_d_i,
					 &PLID, surface_point_tmp, &found);
			
			//printf("%d\n",PLID);
			
			
			
			//printf("%d %d %lf\n",i+1,PLID,incidence*dpr_c());
			
			
			if(PLID != 0 && PLID == i+1){
				//if(incidence*dpr_c() < 90){
				//printf("%d\t%lf\n",i+1,incidence);
				dskn02_c(handle, &dladsc, i+1, plnorm);
				incidence = vsep_c(solar_pos_bd_d,plnorm);
				plateCdata[i][0] = cos(incidence);
				plateCdata[i][1] = cos(incidence);
				plateCdata[i][2] = cos(incidence);
				count++;
				
				/*
				 if(incidence > 0 && incidence*dpr_c() < 90){
				 //printf("%d\n",PLID);
				 }
				 */
			}
			else{
				plateCdata[i][0] = 0.01;
				plateCdata[i][1] = 0.01;
				plateCdata[i][2] = 0.01;
			}
			/*
			 else if(incidence*dpr_c() < 92){
			 printf("%d\t%lf\n",i+1,incidence*dpr_c());
			 }
			 */ 
			
			
			
		}
		
		start = start + nread;
		remain = remain - nread;
		
	}
	//printf("%d\n",count);
	
	dascls_c( handle );
	
	return plateCdata;
}

double* ShadowRender:: getSunPosition(){
	return solar_pos_bd;
}