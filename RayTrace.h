/*
 *  RayTrace.h
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/06/18.
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

#include "MyVector3D.h"
#include <string>

using namespace std;

class RayTrace{

public: int CollisionDetect(MyVector3D,MyVector3D,string);
	
};