/*
 *  RayTrace.cpp
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/06/18.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "RayTrace.h"

int RayTrace::CollisionDetect(MyVector3D prerover, MyVector3D rover, string dskfilepath){
// general purpose variables


	SpiceDouble prerover_bd[3];
	SpiceDouble rover_bd[3],rover_bd_d[3],rover_bd_d_i[3];





SpiceInt    PLID;
	SpiceInt found;
SpiceDouble surface_point_tmp[3];

SpiceInt                handle;
SpiceDLADescr dladsc;
	prerover_bd[0] = prerover.x;
	prerover_bd[1] = prerover.y;
	prerover_bd[2] = prerover.z;
	rover_bd[0] = rover.x;
	rover_bd[1] = rover.y;
	rover_bd[2] = rover.z;
	
///DSK file ?
///Open DSK file
dasopr_c ( dskfilepath.c_str() , &handle );
/*
 Begin a forward search through the
 kernel, treating the file as a DLA.
 In this example, it's a very short
 search.
 */
//serch the kernel in the DSK file.
//If not find DSK file, found is 0.
dlabfs_c ( handle, &dladsc, &found );




//printf("%s is loaded.\n",argv[4]);
	
		vsub_c(prerover_bd,rover_bd,rover_bd_d);
		vminus_c(rover_bd_d,rover_bd_d_i);
		dskx02_c(handle, &dladsc, prerover_bd, rover_bd_d_i,
				 &PLID, surface_point_tmp, &found);
		
		//printf("%d\n",PLID);
		
		
		//printf("%d %d %lf\n",i+1,PLID,incidence*dpr_c());
		
	if( !found ){
		return -1;
	}
	else{
		return PLID;
	}
		
	


dascls_c( handle );


}