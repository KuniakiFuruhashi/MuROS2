/*
 *  GetData.h
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/04/13.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */
extern "C" {
#include "SpiceUsr.h"
#include "SpiceDLA.h"
#include "SpiceDSK.h"
#include <stdio.h>
#include "dsk_proto.h"
#include "f2c_proto.h"
#include "pl02.h"
}

#include <map>
#include <set>
#include <vector>
#include <string>

using namespace std;
class GetData
{
public: GetData(void);
public: GetData(string,string);
public: int getNumberOfPlate(void);
public: int getNumberOfVertices(void);
public: void readPlateData(SpiceInt,SpiceDLADescr);
public: void readVerticesData(SpiceInt,SpiceDLADescr);
public: int** getPlateData(void);
public: double** getVerticesData(void);
public: int** getCommonF(void);	
	vector<int>* getppp(void);
	vector<int>* getppm(void);
	vector<int>* getpmp(void);
	vector<int>* getmpp(void);
	vector<int>* getpmm(void);
	vector<int>* getmpm(void);
	vector<int>* getmmp(void);
	vector<int>* getmmm(void);
	
	
};

