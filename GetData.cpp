/*
 *  GetData.cpp
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/04/13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "GetData.h"



SpiceDLADescr dladsc;
SpiceBoolean found;
SpiceInt nv;
SpiceInt np;
SpiceInt nvxtot;
SpiceDouble vtxbds[3][2];
SpiceDouble voxsize;
SpiceDouble voxori[3];
SpiceInt vgrext[3];
SpiceInt cgscal;
SpiceInt vtxnpl;
SpiceInt voxnpt;
SpiceInt voxnpl;

SpiceDouble vrtces[3][3];
SpiceInt start;
SpiceInt n;
SpiceInt i;
SpiceInt j;
SpiceInt vrtids[3];
int** pd;
int** commonF;
double** vd;

vector<int> ppp;
vector<int> ppm;
vector<int> pmp;
vector<int> mpp;
vector<int> pmm;
vector<int> mpm;
vector<int> mmp;
vector<int> mmm;

GetData::GetData(void){
	
	
	
}

GetData::GetData(string dskfilepath, string currentPath){
	
	SpiceInt handle;
	SpiceDLADescr dladsc;
	//int i,j,k,l,norme1,norme2,p,q;
	//int flag = 0;
	//int cont;
	FILE *f;
	printf("getdata\n");
	string fname = "/Desktop/commonF_aft.dat";
	fname = currentPath + fname;
	dasopr_c(dskfilepath.c_str(), &handle);
	dlabfs_c(handle,&dladsc,&found);
	//f = fopen("/Users/m5151134/Desktop/commonF_aft.dat", "w");
	f = fopen(fname.c_str(), "w");
	if(!found){
		
		setmsg_c ( "No segments found in DSK file #." );
		sigerr_c ( "SPICE(NODATA)"                    );
			
		
	}
	
	//Get Number of Plate
	dski02_c ( handle, &dladsc, SPICE_DSK_KWNP, 
			  0,      1,       &n,             &np );
	
	pd = new int*[np];
	pd[0] = new int[np * 3];
	for (i = 1; i < np; i++) pd[i] = pd[0] + i * 3;
	
	//Get Number of Vertices
	dski02_c ( handle, &dladsc, SPICE_DSK_KWNV, 
			  0,      1,       &n,             &nv );
	
	vd = new double*[nv];
	vd[0] = new double[nv*3];
	for (i = 1; i < nv; i++) vd[i] = vd[0] + i * 3;
	
	readPlateData(handle,dladsc);
	readVerticesData(handle,dladsc);
	
	
	dascls_c ( handle );

	/*
for (i = 0 ; i < nv ; i++) {
	printf("%d %d %d %d %d\n",i,nv,pd[i][0],pd[i][1],pd[i][2]);
}	
	*/
	int fppp=0,fppm=0,fpmp=0,fmpp=0,fpmm=0,fmpm=0,fmmp=0,fmmm=0;
	for ( i = 0 ; i < np ; i++) {
		for ( int j = 0 ; j < 3 ; j++) {
//printf("check:%d %d %d %d %d\n",i,j,nv,np,pd[i][j]);
			double x = vd[pd[i][j]-1][0];
			double y = vd[pd[i][j]-1][1];
			double z = vd[pd[i][j]-1][2];
			
			//+x+y+z
			if (x >= 0 && y >= 0 && z>= 0 && fppp == 0) {
				ppp.push_back(i+1);
				fppp = 1;
			}
			//+x+y-z
			if (x >= 0 && y >= 0 && z <= 0 && fppm == 0) {
				ppm.push_back(i+1);
				fppm = 1;
			}
			//+x-y+z
			if (x >= 0 && y <= 0 && z >= 0 && fpmp == 0) {
				pmp.push_back(i+1);
				fpmp = 1;
			}
			//-x+y+z
			if (x <= 0 && y >= 0 && z >= 0 && fmpp == 0) {
				mpp.push_back(i+1);
				fmpp = 1;
			}
			//+x-y-z
			if (x >= 0 && y <= 0 && z <= 0 && fpmm == 0) {
				pmm.push_back(i+1);
				fpmm = 1;
			}
			//-x+y-z
			if (x <= 0 && y >= 0 && z <= 0 && fmpm == 0) {
				mpm.push_back(i+1);
				fmpm = 1;
			}
			//-x-y+z
			if (x <= 0 && y <= 0 && z >= 0 && fmmp == 0) {
				mmp.push_back(i+1);
				fmmp = 1;
			}
			//-x-y-z
			if (x <= 0 && y <= 0 && z <= 0 && fmmm == 0) {
				mmm.push_back(i+1);
				fmmm = 1;
			}
		}
		fppp=0;
		fppm=0;
		fpmp=0;
		fmpp=0;
		fpmm=0;
		fmpm=0;
		fmmp=0;
		fmmm=0;
	}
	
	
		
	
	commonF = new int*[np];
	commonF[0] = new int[np * 3];
	for (i = 1; i < np; i++) commonF[i] = commonF[0] + i * 3;
	
	/*
	for( i = 0 ; i < np ; i++){
		printf("nv:%d np:%d pd0:%d p1:%d p2:%d\n",nv,np,pd[i][0],pd[i][1],pd[i][2]);
	}
	*/
	
	
	
	map<int,set<int> > dict;
	for(int i = 0; i < np; ++i){
		for(int j = 0; j < 3; ++j){
			dict[pd[i][j]].insert(i);
		}
	}
	
	int *conts = new int[np];
	for(int i = 0; i < np; ++i){
		conts[i] = 0;
	}
	for(int i = 0; i < np; ++i){
		set<int> ids;
		for(int j = 0; j < 3; ++j){
			for(set<int>::iterator it = dict[pd[i][j]].begin(); it != dict[pd[i][j]].end(); ++it){
				ids.insert( *it );
			}
		}
		int cnt = 0;
		int id_array[ids.size()];
		for(set<int>::iterator it = ids.begin(); it != ids.end(); ++it){
			id_array[cnt++] = *it;
		}
		for(int j = 0; j < ids.size(); ++j){
            int fid = 0;
            fid = id_array[j];
			for(int k = 0; k < ids.size(); ++k){
                int sid = 0;
                sid = id_array[k];
				if( fid != sid ){
					
					for(int ii = 0; ii < 3; ++ii){
						int norme1 = pd[fid][ii];
						int norme2 = pd[fid][(ii+1)%3];
						
						for(int jj = 0; jj < 3; ++jj){
							int normf1 = pd[sid][jj];
							int normf2 = pd[sid][(jj+1)%3];
							
							if( (norme1 == normf1 && norme2 == normf2) || (norme1 == normf2 && norme2 == normf1) ){
								if( conts[fid] >= 3 ) continue;
								bool ng = false;
								for(int kk = 0; kk < conts[fid]; ++kk){
									if( commonF[fid][kk] == sid+1 ){
										ng = true;
									}
								}
								if( !ng ){
									commonF[fid][conts[fid]++] = sid+1;
								}
							}
						}
					}
				}
			}
		}			
	}
	 
	//printf("getdata: %d",commonF[0][0]);
	fclose(f);
}

int GetData::getNumberOfPlate(void){
	return np;
}

int GetData::getNumberOfVertices(void){
	return nv;
}



void GetData::readPlateData(SpiceInt handle,SpiceDLADescr dladsc)
{
	SpiceInt n;
	SpiceInt start;
	int i;
	
	//dasopr_c("/Users/m5151134/kernels/generic_kernels/dsk/hay_a_amica_5_itokawashape_v1_0_64q.bds.txt", &handle);
	dlabfs_c(handle,&dladsc,&found);
	
	for( i = 1 ; i <= np ; i++ ){
		
		start = 3*(i-1);
		
		dski02_c ( handle, &dladsc, SPICE_DSK_KWPLAT, start,  
				  3,      &n,      pd[i-1]                   );
		
	}
	//dascls_c ( handle );
	
}



void GetData::readVerticesData(SpiceInt handle,SpiceDLADescr dladsc){
	SpiceInt n;
	SpiceInt start;
	int i;
	
	//dasopr_c("/Users/m5151134/kernels/generic_kernels/dsk/hay_a_amica_5_itokawashape_v1_0_64q.bds.txt", &handle);
	dlabfs_c(handle,&dladsc,&found);
	
	
	for ( i = 1;  i <= nv;  i++ )
	{
		start = 3*(i-1);
		
		dskd02_c ( handle, &dladsc, SPICE_DSK_KWVERT, start,  
				  3,      &n,      vd[i-1]               );
	}
	//printf("getData %lf",vd[0][0]);
	//dascls_c ( handle );
	
	
}

int** GetData::getPlateData(void){
	return pd;
}

double** GetData::getVerticesData(void){			
	return vd;
}

int** GetData::getCommonF(void)
{
	return commonF;	
	
}

vector<int>* GetData::getppp(void)
{
	return &ppp;
}

vector<int>* GetData::getppm(void)
{
	return &ppm;
}

vector<int>* GetData::getpmp(void)
{
	return &pmp;
}

vector<int>* GetData::getmpp(void)
{
	return &mpp;
}

vector<int>* GetData::getpmm(void)
{
	return &pmm;
}

vector<int>* GetData::getmpm(void)
{
	return &mpm;
}

vector<int>* GetData::getmmp(void)
{
	return &mmp;
}

vector<int>*GetData::getmmm(void)
{
	return &mmm;
}
 
 
