//
//  CalcTrajectory.mm
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/05/19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CalcTrajectory.h"


@implementation CalcTrajectory

@synthesize ppp,ppm,pmp,mpp,pmm,mpm,mmp,mmm;


-(void)vp:(MyVector3D)vp normalVec:(MyVector3D)norm verticesData:(double **)vData plateData:(int **)pData commonFData:(int **)commonF numberOfvertices:(int)numberOfvertices numberOfplate:(int)numberOfplate InitPX:(double)Initpx InitPY:(double)Initpy InitPZ:(double)Initpz InitVX:(double)Initvx InitVY:(double)Initvy InitVZ:(double)Initvz fai:(double)fai theta:(double)theta rotationAV:(double)w density:(double)density stepsize:(double)h limit:(double)limit e:(double)e dskfile:(string)dskfile rsize:(double)rsize rmass:(double)rmass roverAV:(double)rw rotationAxis:(MyVector3D)rotationAxis
{

		
	
	FILE *outputfile;
	FILE *outputfile_rover;
	
	MyVector3D rover;
	MyVector3D pre_rover;
	MyVector3D pre_v;
	MyVector3D rover_v;

	MyVector3D np(0.0,0.0,10.0);
	
	
	GravitationCalculator gravitation;
	GravitationCalculator v_gravitation;
	int v_colpId[8] = {-1,-1,-1,-1,-1,-1,-1,-1};
	int v_precolpId[8] = {-1,-1,-1,-1,-1,-1,-1,-1};
	int randflag[8] = {0,0,0,0,0,0,0,0};
	double t = 0;
	
    vp.x=Initpx;//Position X
    vp.y=Initpy;//Position Y
    vp.z=Initpz;//Position Z

    
    
    printf("start: %e %e %e \n",vp.x,vp.y,vp.z);
   
    double rad_fai = [self toRadian:fai];
	double rad_theta = [self toRadian:theta];
	
	//double laplas = -12;
	double v_laplas[8] = {-12,-12,-12,-12,-12,-12,-12,-12};
		
	//double pre_laplas = 0;
	double v_prelaplas[8] = {0,0,0,0,0,0,0,0};

    double h1[8]={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
	double h2[8]={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
	
	int collisionId=-1;
	MyVector3D ver_rover;//ローバの頂点座標用
	MyVector3D ver_prerover;
	
	double o;
	double p;
	double q;
	double yk,yk1,yk2,yk3,yk4;
	double xk,xk1,xk2,xk3,xk4;
	double zk,zk1,zk2,zk3,zk4;
	double ok,ok1,ok2,ok3,ok4;
	double pk,pk1,pk2,pk3,pk4;
	double qk,qk1,qk2,qk3,qk4;
	
    double v0=0.0;
	MyVector3D n(v0*norm.x,v0*norm.y,v0*norm.z);
	MyVector3D equa;
	MyVector3D drect;
	MyVector3D rvec;
	MyVector3D gvec;
	MyVector3D pre_rvec;
	MyVector3D vvec;
	MyVector3D pre_vvec;
	
	
	currentPath = NSHomeDirectory();
	string fname = "/Desktop/trajectory_data.txt";
	string frname = "/Desktop/roverShape_data.txt";
	fname = [currentPath UTF8String] + fname;
	frname = [currentPath UTF8String] + frname;
	//outputfile = fopen("/Users/m5151134/Desktop/trajectory_data.txt", "w");
	outputfile = fopen(fname.c_str() , "w");
	outputfile_rover = fopen(frname.c_str(), "w");
	if (outputfile == NULL) {
		printf("cannot open\n");
		exit(1);
	}
	if (outputfile_rover == NULL) {
		printf("cannot open rover shape file\n");
		exit(1);
	}
	
	equa.cross(norm, rotationAxis);
	drect.cross(equa, norm);
	minerva = Rover(rsize, vp.x, vp.y, vp.z,rmass);//ローバーのサイズ、XYZの初期位置、質量
	minerva.setAttiRover(norm, vp, drect, theta);//法線ベクトル、初速、方位角、射出角
	//minerva.rotateRover_axis(0*M_PI/180.0, minerva.rtY);
	///equa.normalize();
	//最初の回転軸の設定：回転軸はローバのZ軸
	//角速度ベクトルは回転させる関数(rotateRover_vector)に入れる前に座標変換する必要がある
	//ワールド座標系からオブジェクト座標系のZ軸(0,0,1)
	MyVector3D angularV_vector(minerva.rtZ.x*rw, minerva.rtZ.y*rw, minerva.rtZ.z*rw);
	MyVector3D object_angularV;
	double detA = minerva.rtX.x*minerva.rtY.y*minerva.rtZ.z + minerva.rtX.y*minerva.rtY.z*minerva.rtZ.x + minerva.rtX.z*minerva.rtY.x*minerva.rtZ.y - minerva.rtX.x*minerva.rtY.z*minerva.rtZ.y - minerva.rtX.z*minerva.rtY.y*minerva.rtZ.x - minerva.rtX.y*minerva.rtY.x*minerva.rtZ.z;
	object_angularV.setParameter(((minerva.rtY.y*minerva.rtZ.z-minerva.rtZ.y*minerva.rtY.z)/detA*angularV_vector.x) + ((minerva.rtZ.x*minerva.rtY.z-minerva.rtY.x*minerva.rtZ.z)/detA*angularV_vector.y) + ((minerva.rtY.x*minerva.rtZ.y-minerva.rtZ.x*minerva.rtY.y)/detA*angularV_vector.z),
							((minerva.rtZ.y*minerva.rtX.z-minerva.rtX.y*minerva.rtZ.z)/detA*angularV_vector.x) + ((minerva.rtX.x*minerva.rtZ.z-minerva.rtZ.x*minerva.rtX.z)/detA*angularV_vector.y) + ((minerva.rtZ.x*minerva.rtX.y-minerva.rtX.x*minerva.rtZ.y)/detA*angularV_vector.z),
							((minerva.rtX.y*minerva.rtY.z-minerva.rtY.y*minerva.rtX.z)/detA*angularV_vector.x) + ((minerva.rtY.x*minerva.rtX.z-minerva.rtX.x*minerva.rtY.z)/detA*angularV_vector.y) + ((minerva.rtX.x*minerva.rtY.y-minerva.rtY.x*minerva.rtX.y)/detA*angularV_vector.z));
	

	printf("Initial angularVector: %e %e %e %e\n",angularV_vector.x,angularV_vector.y,angularV_vector.z,angularV_vector.length()*180.0/M_PI);

	double x = minerva.cx*1000.0;
	double y = minerva.cy*1000.0;
	double z = minerva.cz*1000.0;
	
	equa.cross(np, n);
	drect.cross(n, equa);
	equa.normalize();
	
	
	MyVector3D temp_V;
	temp_V = temp_V.rotate(equa, n, rad_fai);
	norm.normalize();
	n.normalize();
	
	MyVector3D v;
	v = v.rotate(norm, temp_V, rad_theta);
	printf("v0:%lf\n",v.length());
	
    v.x=Initvx; //acc. X
    v.y=Initvy; //acc. Y
    v.z=Initvz; //acc. Z
	rover_v.setParameter(v.x, v.y, v.z);
	printf("initial V: %lf %lf %lf %lf \n",v.x,v.y,v.z,v.length());
    printf("mode is not inlcude sun position calc.\n\n");
    
	o = rover_v.x;
    p = rover_v.y;
	q = rover_v.z;
	
    
	rover.setParameter(x/1000.0, y/1000.0, z/1000.0);
	gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
	
    fprintf(outputfile, "%lf\t%lf\t%d\n",h,limit,0);//
	fprintf(outputfile, "%f\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%d\t%1.6E\t%1.6E\t%1.6E\n",
			t,rover.x,rover.y,rover.z,rover.length(),o/1000.0,p/1000.0,q/1000.0,object_angularV.x,object_angularV.y,object_angularV.z,gravitation.u,
			minerva.b_point[0][0],minerva.b_point[0][1],minerva.b_point[0][2],
			minerva.b_point[1][0],minerva.b_point[1][1],minerva.b_point[1][2],
			minerva.b_point[2][0],minerva.b_point[2][1],minerva.b_point[2][2],
			minerva.b_point[3][0],minerva.b_point[3][1],minerva.b_point[3][2],
			minerva.b_point[4][0],minerva.b_point[4][1],minerva.b_point[4][2],
			minerva.b_point[5][0],minerva.b_point[5][1],minerva.b_point[5][2],
			minerva.b_point[6][0],minerva.b_point[6][1],minerva.b_point[6][2],
			minerva.b_point[7][0],minerva.b_point[7][1],minerva.b_point[7][2],-1,0.0,0.0,0.0);
    /* １０個 */

	t+=h;
    
    printf("Check point\n\n");
    
    //ここからがとても計算かかっているところっぽい
    clock_t start,end;
	start = clock();
	while (TRUE) {
        
		pre_v = MyVector3D(v.x,v.y,v.z);
		pre_rover = MyVector3D(rover.x,rover.y,rover.z);
		minerva.setPreRoverPosition();
		
		yk1 = h*[self fy_t:t fy_p:p];
		xk1 = h*[self fx_t:t fx_o:o];
		zk1 = h*[self fz_t:t fz_q:q];
		pk1 = h*[self fp_x:x fp_y:y fp_z:z fp_o:o fp_p:p fp_q:q fp_t:t fp_w:w fp_gy:gvec.y*1000.0];
		ok1 = h*[self fo_x:x fo_y:y fo_z:z fo_o:o fo_p:p fo_q:q fo_t:t fo_w:w fo_gx:gvec.x*1000.0];
		qk1 = h*[self fq_x:x fq_y:y fq_z:z fq_o:o fq_p:p fq_q:q fq_t:t fq_w:w fq_gz:gvec.z*1000.0];
		
		yk2 = h*[self fy_t:t+h/2.0 fy_p:p+pk1/2.0];
		xk2 = h*[self fx_t:t+h/2.0 fx_o:o+ok1/2.0];
		zk2 = h*[self fz_t:t+h/2.0 fz_q:q+qk1/2.0];
		rover.x = (x+(xk1/2.0))/1000.0; rover.y = (y+(yk1/2.0))/1000.0; rover.z = (z+(zk1/2.0))/1000.0;
		gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
		pk2 = h*[self fp_x:x+xk1/2.0 fp_y:y+yk1/2.0 fp_z:z+zk1/2.0 fp_o:o+ok1/2.0 fp_p:p+pk1/2.0 fp_q:q+qk1/2.0 fp_t:t+h/2.0 fp_w:w fp_gy:gvec.y*1000.0];
		ok2 = h*[self fo_x:x+xk1/2.0 fo_y:y+yk1/2.0 fo_z:z+zk1/2.0 fo_o:o+ok1/2.0 fo_p:p+pk1/2.0 fo_q:q+qk1/2.0 fo_t:t+h/2.0 fo_w:w fo_gx:gvec.x*1000.0];
		qk2 = h*[self fq_x:x+xk1/2.0 fq_y:y+yk1/2.0 fq_z:z+zk1/2.0 fq_o:o+ok1/2.0 fq_p:p+pk1/2.0 fq_q:q+qk1/2.0 fq_t:t+h/2.0 fq_w:w fq_gz:gvec.z*1000.0];
		
		yk3 = h*[self fy_t:t+h/2.0 fy_p:p+pk2/2.0];
		xk3 = h*[self fx_t:t+h/2.0 fx_o:o+ok2/2.0];
		zk3 = h*[self fz_t:t+h/2.0 fz_q:q+qk2/2.0];
		rover.x = (x+(xk2/2.0))/1000.0; rover.y = (y+(yk2/2.0))/1000.0; rover.z = (z+(zk2/2.0))/1000.0;
		gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
		pk3 = h*[self fp_x:x+xk2/2.0 fp_y:y+yk2/2.0 fp_z:z+zk2/2.0 fp_o:o+ok2/2.0 fp_p:p+pk2/2.0 fp_q:q+qk2/2.0 fp_t:t+h/2.0 fp_w:w fp_gy:gvec.y*1000.0];
		ok3 = h*[self fo_x:x+xk2/2.0 fo_y:y+yk2/2.0 fo_z:z+zk2/2.0 fo_o:o+ok2/2.0 fo_p:p+pk2/2.0 fo_q:q+qk2/2.0 fo_t:t+h/2.0 fo_w:w fo_gx:gvec.x*1000.0];
		qk3 = h*[self fq_x:x+xk2/2.0 fq_y:y+yk2/2.0 fq_z:z+zk2/2.0 fq_o:o+ok2/2.0 fq_p:p+pk2/2.0 fq_q:q+qk2/2.0 fq_t:t+h/2.0 fq_w:w fq_gz:gvec.z*1000.0];
		
		yk4 = h*[self fy_t:t+h fy_p:p+pk3];
		xk4 = h*[self fx_t:t+h fx_o:o+ok3];
		zk4 = h*[self fz_t:t+h fz_q:q+qk3];
		rover.x = (x+xk3)/1000.0; rover.y = (y+yk3)/1000.0; rover.z = (z+zk3)/1000.0;
		
		gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
		pk4 = h*[self fp_x:x+xk3 fp_y:y+yk3 fp_z:z+zk3 fp_o:o+ok3 fp_p:p+pk3 fp_q:q+qk3 fp_t:t+h fp_w:w fp_gy:gvec.y*1000.0];
		ok4 = h*[self fo_x:x+xk3 fo_y:y+yk3 fo_z:z+zk3 fo_o:o+ok3 fo_p:p+pk3 fo_q:q+qk3 fo_t:t+h fo_w:w fo_gx:gvec.x*1000.0];
		qk4 = h*[self fq_x:x+xk3 fq_y:y+yk3 fq_z:z+zk3 fq_o:o+ok3 fq_p:p+pk3 fq_q:q+qk3 fq_t:t+h fq_w:w fq_gz:gvec.z*1000.0];
		
		yk = (yk1+2*yk2+2*yk3+yk4)/6.0;
		xk = (xk1+2*xk2+2*xk3+xk4)/6.0;
		zk = (zk1+2*zk2+2*zk3+zk4)/6.0;
		pk = (pk1+2*pk2+2*pk3+pk4)/6.0;
		ok = (ok1+2*ok2+2*ok3+ok4)/6.0;
		qk = (qk1+2*qk2+2*qk3+qk4)/6.0;
		
		y+=yk;
		x+=xk;
		z+=zk;
		p+=pk;
		o+=ok;
		q+=qk;
		
		rover.setParameter(x/1000.0, y/1000.0, z/1000.0);
		v.setParameter(o, p, q);
		minerva.moveRover(rover.x, rover.y, rover.z);
		minerva.rotateRover_vector(object_angularV,h);
		gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
	
		
		//レイトレース（形状付き）
		//立方体の８点、それぞれを見る
		double drx,dry,drz;
		double ja; //力積
		double min;
		int collisionPNum;
		int laplacianflag = 0;
		int flag = 0;
		MyVector3D r[8]; //重心から衝突点へのベクトル
		MyVector3D wr; //角速度ベクトルとrとの外積
		MyVector3D pa; //衝突点での合成速度
		MyVector3D rXn;//rと法線ベクトルとの外積
		MyVector3D iXrn; //慣性モーメントとrXnとの外積
		MyVector3D irnXr; //iXrnとrとの外積
		MyVector3D jN; //法線ベクトルに力積jをかけたもの
		MyVector3D rXjn; //rとjNとの外積
		MyVector3D near_pNormal;
		MyVector3D v_velocity[8];
		MyVector3D v_angvelocity[8];
		
		
		//各頂点が衝突していないか確認
		for (int i = 0; i < 8; i++) {
			ver_rover.setParameter(minerva.b_point[i][0], minerva.b_point[i][1],minerva.b_point[i][2]);
			ver_prerover.setParameter(minerva.preb_point[i][0], minerva.preb_point[i][1], minerva.preb_point[i][2]);
			gvec = v_gravitation.calculateG(ver_rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
			v_prelaplas[i] = v_laplas[i];
			v_laplas[i] = v_gravitation.laplas;
			
			//ラプラシアンでの前処理
			if (v_laplas[i] <= -6 || randflag[i] == 1) {
				if (v_laplas[i] < -12) {
					laplacianflag = 1;
                    printf("Break point A\n\n");
					break;
				}
				randflag[i] = 1;

				RayTrace v_rayt;
				v_precolpId[i] = v_colpId[i];
				//レイトレースを行う
				v_colpId[i] = v_rayt.CollisionDetect(ver_prerover, ver_rover, dskfile);
				CalLib clb;
				
				//光線（レイ）に当たっているポリゴンがあれば衝突
				if (v_colpId[i] > 0) {
					near_pNormal = clb.getNormalVector(v_colpId[i]-1, vData, pData);
					MyVector3D near_pCenter = clb.getGravityCenter(v_colpId[i]-1, vData, pData);
					
					//前のステップと現在のステップでの位置ベクトルとポリゴンの法線ベクトルとの内積をとる
					h1[i] = near_pNormal.dot(MyVector3D(ver_rover.x - near_pCenter.x, ver_rover.y - near_pCenter.y, ver_rover.z - near_pCenter.z));
					h2[i] = near_pNormal.dot(MyVector3D(ver_prerover.x - near_pCenter.x, ver_prerover.y - near_pCenter.y, ver_prerover.z - near_pCenter.z));

					
					//符号が違うのであれば、現在のステップと前のステップの間に衝突をしていると判定
					if(h1[i]*h2[i] <= 0){
						min = h2[i];
						collisionPNum = i;
						printf("Step: %lf i:%d raytrace:%d %lf h1:%lf h2:%lf\n",t,i,v_colpId[i]-1,t,h1[i],h2[i]);
						
						//衝突点を求める
						MyVector3D collisionPoint((ver_prerover.x*fabs(h1[i]) + ver_rover.x*fabs(h2[i]))/(fabs(h1[i])+fabs(h2[i])),
												  (ver_prerover.y*fabs(h1[i]) + ver_rover.y*fabs(h2[i]))/(fabs(h1[i])+fabs(h2[i])),
												  (ver_prerover.z*fabs(h1[i]) + ver_rover.z*fabs(h2[i]))/(fabs(h1[i])+fabs(h2[i])));
						
						if (flag == 0) {
							drx = minerva.b_point[i][0] - collisionPoint.x;
							dry = minerva.b_point[i][1] - collisionPoint.y;
							drz = minerva.b_point[i][2] - collisionPoint.z;
							rover.x = rover.x - drx;
							rover.y = rover.y - dry;
							rover.z = rover.z - drz;
						}
						flag += 1;
						r[i].setParameter(collisionPoint.x - rover.x, collisionPoint.y - rover.y, collisionPoint.z - rover.z);
						wr.cross(angularV_vector, r[i]);
						pa.setParameter(v.x + wr.x, v.y + wr.y, v.z + wr.z);
						printf("i:%d pa:%e %e %e %e\n",i,pa.x,pa.y,pa.z,near_pNormal.dot(pa));
						
						rXn.cross(r[i], near_pNormal);
						iXrn.x = (minerva.rtX.x*minerva.rtX.x*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.x*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.x*minerva.Iinv.z)*rXn.x + 
						(minerva.rtX.x*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.y*minerva.Iinv.z)*rXn.y +
						(minerva.rtX.x*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.z*minerva.Iinv.z)*rXn.z;
						
						iXrn.y = (minerva.rtX.x*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.y*minerva.Iinv.z)*rXn.x +
						(minerva.rtX.y*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.y*minerva.Iinv.z)*rXn.y +
						(minerva.rtX.y*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.z*minerva.Iinv.z)*rXn.z;
						
						iXrn.z = (minerva.rtX.x*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.z*minerva.Iinv.z)*rXn.x +
						(minerva.rtX.y*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.z*minerva.Iinv.z)*rXn.y + 
						(minerva.rtX.z*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.z*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.z*minerva.rtZ.z*minerva.Iinv.z)*rXn.z;
						
						irnXr.cross(iXrn, r[i]);
						ja = -((1 + e)*(near_pNormal.dot(pa)))/((1/minerva.rmass)+near_pNormal.dot(irnXr));
						jN.setParameter(ja*near_pNormal.x, ja*near_pNormal.y, ja*near_pNormal.z);
						rXjn.cross(r[i], jN);
						
						v_velocity[i].setParameter(ja*near_pNormal.x/minerva.rmass, ja*near_pNormal.y/minerva.rmass, ja*near_pNormal.z/minerva.rmass);
						
						v_angvelocity[i].x = (pow(minerva.rtX.x,2)*minerva.Iinv.x + pow(minerva.rtY.x,2)*minerva.Iinv.y + pow(minerva.rtZ.x,2)*minerva.Iinv.z)*rXjn.x + 
						(minerva.rtX.x*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.y*minerva.Iinv.z)*rXjn.y +
						(minerva.rtX.x*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.z*minerva.Iinv.z)*rXjn.z;
						
						v_angvelocity[i].y = (minerva.rtX.x*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.y*minerva.Iinv.z)*rXjn.x +
						(minerva.rtX.y*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.y*minerva.Iinv.z)*rXjn.y +
						(minerva.rtX.y*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.z*minerva.Iinv.z)*rXjn.z;
						
						v_angvelocity[i].z = (minerva.rtX.x*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.z*minerva.Iinv.z)*rXjn.x +
						(minerva.rtX.y*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.z*minerva.Iinv.z)*rXjn.y + 
						(minerva.rtX.z*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.z*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.z*minerva.rtZ.z*minerva.Iinv.z)*rXjn.z;
						
						printf("collision point: %e %e %e\n",collisionPoint.x,collisionPoint.y,collisionPoint.z);
						printf("rover: %e %e %e\n",rover.x,rover.y,rover.z);
						printf("J=%e\n",ja);

						
					}//end of if(h1*h2 <= 0)
					else if(h1[i] < 0 && h2[i] < 0){
						printf("end h1<0 h2<0\n");
						break;
					}
					else {
						v_velocity[i].setParameter(0, 0, 0);
						v_angvelocity[i].setParameter(0, 0, 0);
						h1[i] = 0;
						h2[i] = 0;
					}
				}//end of if (v_colpId[i] > 0)
			}//end of if(v_laplas[i] <= -6....	
		}// end of for (int i = 0; i < 8; i++)
		
		
		
		//衝突点があったら
		if (flag != 0) {
			printf("prev: %e %e %e %e\n",v.x,v.y,v.z,v.length());
			for (int j = 0;  j < 8; j ++) {
			
				if (h2[j] != 0 && h2[j] <= min) {
					min = h2[j];
					collisionPNum = j;
					collisionId = v_colpId[j];
				}
				randflag[j] = 0;
			}
			
			v.x += v_velocity[collisionPNum].x;
			v.y += v_velocity[collisionPNum].y;
			v.z += v_velocity[collisionPNum].z;
			angularV_vector.x += v_angvelocity[collisionPNum].x;
			angularV_vector.y += v_angvelocity[collisionPNum].y;
			angularV_vector.z += v_angvelocity[collisionPNum].z;
			printf("i:%d v: %e %e %e L:%e\n",collisionPNum,v_velocity[collisionPNum].x,v_velocity[collisionPNum].y,v_velocity[collisionPNum].z,v_velocity[collisionPNum].length());
			MyVector3D awr;
			MyVector3D apa;
			awr.cross(angularV_vector, r[collisionPNum]);
			apa.setParameter(v.x+awr.x,v.y+awr.y,v.z+awr.z);
			printf("after p: %e %e %e %e\n",apa.x,apa.y,apa.z,near_pNormal.dot(apa));
			o = v.x;
			p = v.y;
			q = v.z;
			printf("prec: %e %e %e\n",minerva.cx,minerva.cy,minerva.cz);
			minerva.moveRover(rover.x, rover.y, rover.z);
			//角速度ベクトルが変化したのでまた、座標変換したベクトルを定義
			detA = minerva.rtX.x*minerva.rtY.y*minerva.rtZ.z + minerva.rtX.y*minerva.rtY.z*minerva.rtZ.x + minerva.rtX.z*minerva.rtY.x*minerva.rtZ.y - minerva.rtX.x*minerva.rtY.z*minerva.rtZ.y - minerva.rtX.z*minerva.rtY.y*minerva.rtZ.x - minerva.rtX.y*minerva.rtY.x*minerva.rtZ.z;
			object_angularV.setParameter(((minerva.rtY.y*minerva.rtZ.z-minerva.rtZ.y*minerva.rtY.z)/detA*angularV_vector.x) + ((minerva.rtZ.x*minerva.rtY.z-minerva.rtY.x*minerva.rtZ.z)/detA*angularV_vector.y) + ((minerva.rtY.x*minerva.rtZ.y-minerva.rtZ.x*minerva.rtY.y)/detA*angularV_vector.z),
										 ((minerva.rtZ.y*minerva.rtX.z-minerva.rtX.y*minerva.rtZ.z)/detA*angularV_vector.x) + ((minerva.rtX.x*minerva.rtZ.z-minerva.rtZ.x*minerva.rtX.z)/detA*angularV_vector.y) + ((minerva.rtZ.x*minerva.rtX.y-minerva.rtX.x*minerva.rtZ.y)/detA*angularV_vector.z),
										 ((minerva.rtX.y*minerva.rtY.z-minerva.rtY.y*minerva.rtX.z)/detA*angularV_vector.x) + ((minerva.rtY.x*minerva.rtX.z-minerva.rtX.x*minerva.rtY.z)/detA*angularV_vector.y) + ((minerva.rtX.x*minerva.rtY.y-minerva.rtY.x*minerva.rtX.y)/detA*angularV_vector.z));
			printf("c: %e %e %e\n",minerva.cx,minerva.cy,minerva.cz);
			printf("v: %e %e %e %e\n",v.x,v.y,v.z,v.length());
			printf("w: %e %e %e %e\n\n",angularV_vector.x,angularV_vector.y,angularV_vector.z,angularV_vector.length()*180.0/M_PI);
			
            if(near_pNormal.dot(apa)  < 1e-3) {// 大半の終了条件はここ
                printf("Break point C\n\n");
                printf("near_pNormal.dot(apa): %lf \n",near_pNormal.dot(apa));
                printf("Rover spped \n ax:%lf ay:%lf az:%lf\n",v.x,v.y,v.z);
				break;
			}
            printf("near_pNormal.dot(apa): %lf \n",near_pNormal.dot(apa));
		}
		
		for (int j = 0 ; j < 8 ; j++) {
			h1[j] = 0;
			h2[j] = 0;
		}
		//レイトレース終了
				
		fprintf(outputfile, "%f\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%d\t%1.6E\t%1.6E\t%1.6E\n",
				t,rover.x,rover.y,rover.z,rover.length(),o/1000.0,p/1000.0,q/1000.0,object_angularV.x,object_angularV.y,object_angularV.z,gravitation.u,
				minerva.b_point[0][0],minerva.b_point[0][1],minerva.b_point[0][2],
				minerva.b_point[1][0],minerva.b_point[1][1],minerva.b_point[1][2],
				minerva.b_point[2][0],minerva.b_point[2][1],minerva.b_point[2][2],
				minerva.b_point[3][0],minerva.b_point[3][1],minerva.b_point[3][2],
				minerva.b_point[4][0],minerva.b_point[4][1],minerva.b_point[4][2],
				minerva.b_point[5][0],minerva.b_point[5][1],minerva.b_point[5][2],
				minerva.b_point[6][0],minerva.b_point[6][1],minerva.b_point[6][2],
				minerva.b_point[7][0],minerva.b_point[7][1],minerva.b_point[7][2],collisionId,0.0,0.0,0.0);
		collisionId = -1;
		
		

		t += h;
        
        if( t > limit ) {
         printf("Break point D\n\n");
        break;    //シミュレーション時間がLimitより超えたら終了
        }
        
	}//whileループ終了
    end=clock();
    printf("end simulate calc , time is %.2fsec. \n",(double)(end-start)/CLOCKS_PER_SEC);
	fclose(outputfile);
	fclose(outputfile_rover);

}
//計算終了
//日照を含めた計算
-(void)vp:(MyVector3D)vp normalVec:(MyVector3D)norm verticesData:(double **)vData plateData:(int **)pData commonFData:(int **)commonF numberOfvertices:(int)numberOfvertices numberOfplate:(int)numberOfplate InitPX:(double)Initpx InitPY:(double)Initpy InitPZ:(double)Initpz InitVX:(double)Initvx InitVY:(double)Initvy InitVZ:(double)Initvz fai:(double)fai theta:(double)theta rotationAV:(double)w density:(double)density stepsize:(double)h limit:(double)limit e:(double)e dskfile:(string)dskfile rsize:(double)rsize rmass:(double)rmass roverAV:(double)rw rotationAxis:(MyVector3D)rotationAxis  sunPosition:(SunPosition)sunP
{
	
	//printf("start: %e %e %e %e\n",vp.vx,vp.vy,vp.vz,[vp length]);
	
	
	FILE *outputfile;
	FILE *outputfile_rover;
	
	MyVector3D rover;
	MyVector3D pre_rover;
	MyVector3D pre_v;
	MyVector3D rover_v;
	
	MyVector3D np(0.0,0.0,10.0);
	double* sun_position;

	
	GravitationCalculator gravitation;
	GravitationCalculator v_gravitation;
	
	//limit = 20;
	//int count = 0;
	int v_colpId[8] = {-1,-1,-1,-1,-1,-1,-1,-1};
	int v_precolpId[8] = {-1,-1,-1,-1,-1,-1,-1,-1};
	int randflag[8] = {0,0,0,0,0,0,0,0};
	//int colpId = -1;
	//int precolpId = -1;
	double t = 0;
	
    vp.x=Initpx;
    vp.y=Initpy;
    vp.z=Initpz;
    
	//double x = vp.x*1000.0;
	//double y = vp.y*1000.0;
	//double z = vp.z*1000.0;
	
	double rad_fai = [self toRadian:fai];
	double rad_theta = [self toRadian:theta];
	
	double laplas = -12;
	double v_laplas[8] = {-12,-12,-12,-12,-12,-12,-12,-12};
	
	//double pre_laplas = 0;
	double v_prelaplas[8] = {0,0,0,0,0,0,0,0};
	
    double h1[8]={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
	double h2[8]={0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0};
	
	int collisionId=-1;
	MyVector3D ver_rover;//ローバの頂点座標用
	MyVector3D ver_prerover;
	
	double o;
	double p;
	double q;
	double yk,yk1,yk2,yk3,yk4;
	double xk,xk1,xk2,xk3,xk4;
	double zk,zk1,zk2,zk3,zk4;
	double ok,ok1,ok2,ok3,ok4;
	double pk,pk1,pk2,pk3,pk4;
	double qk,qk1,qk2,qk3,qk4;
	
    double v0=0.0;
	MyVector3D n(v0*norm.x,v0*norm.y,v0*norm.z);
	MyVector3D equa;
	MyVector3D drect;
	MyVector3D rvec;
	MyVector3D gvec;
	MyVector3D pre_rvec;
	MyVector3D vvec;
	MyVector3D pre_vvec;
	
	
	currentPath = NSHomeDirectory();
	string fname = "/Desktop/trajectory_data.txt";
	string frname = "/Desktop/roverShape_data.txt";
	fname = [currentPath UTF8String] + fname;
	frname = [currentPath UTF8String] + frname;
	//outputfile = fopen("/Users/m5151134/Desktop/trajectory_data.txt", "w");
	outputfile = fopen(fname.c_str() , "w");
	outputfile_rover = fopen(frname.c_str(), "w");
	if (outputfile == NULL) {
		printf("cannot open\n");
		exit(1);
	}
	if (outputfile_rover == NULL) {
		printf("cannot open rover shape file\n");
		exit(1);
	}
	
	equa.cross(norm, rotationAxis);
	drect.cross(equa, norm);
	minerva = Rover(rsize, vp.x, vp.y, vp.z,rmass);
	minerva.setAttiRover(norm, vp, drect, theta);
	minerva.rotateRover_axis(30*M_PI/180.0, minerva.rtY);
	///equa.normalize();
	//最初の回転軸の設定：回転軸はローバのZ軸
	//角速度ベクトルは回転させる関数(rotateRover_vector)に入れる前に座標変換する必要がある
	//ワールド座標系からオブジェクト座標系のZ軸(0,0,1)
	MyVector3D angularV_vector(minerva.rtZ.x*rw, minerva.rtZ.y*rw, minerva.rtZ.z*rw);
	MyVector3D object_angularV;
	double detA = minerva.rtX.x*minerva.rtY.y*minerva.rtZ.z + minerva.rtX.y*minerva.rtY.z*minerva.rtZ.x + minerva.rtX.z*minerva.rtY.x*minerva.rtZ.y - minerva.rtX.x*minerva.rtY.z*minerva.rtZ.y - minerva.rtX.z*minerva.rtY.y*minerva.rtZ.x - minerva.rtX.y*minerva.rtY.x*minerva.rtZ.z;
	object_angularV.setParameter(((minerva.rtY.y*minerva.rtZ.z-minerva.rtZ.y*minerva.rtY.z)/detA*angularV_vector.x) + ((minerva.rtZ.x*minerva.rtY.z-minerva.rtY.x*minerva.rtZ.z)/detA*angularV_vector.y) + ((minerva.rtY.x*minerva.rtZ.y-minerva.rtZ.x*minerva.rtY.y)/detA*angularV_vector.z),
								 ((minerva.rtZ.y*minerva.rtX.z-minerva.rtX.y*minerva.rtZ.z)/detA*angularV_vector.x) + ((minerva.rtX.x*minerva.rtZ.z-minerva.rtZ.x*minerva.rtX.z)/detA*angularV_vector.y) + ((minerva.rtZ.x*minerva.rtX.y-minerva.rtX.x*minerva.rtZ.y)/detA*angularV_vector.z),
								 ((minerva.rtX.y*minerva.rtY.z-minerva.rtY.y*minerva.rtX.z)/detA*angularV_vector.x) + ((minerva.rtY.x*minerva.rtX.z-minerva.rtX.x*minerva.rtY.z)/detA*angularV_vector.y) + ((minerva.rtX.x*minerva.rtY.y-minerva.rtY.x*minerva.rtX.y)/detA*angularV_vector.z));
	//MyVector3D angularV_vector(0*rw, 0*rw, 1*rw);
	
	printf("Initial angularVector: %e %e %e %e\n",angularV_vector.x,angularV_vector.y,angularV_vector.z,angularV_vector.length()*180.0/M_PI);
	
	double x = minerva.cx*1000.0;
	double y = minerva.cy*1000.0;
	double z = minerva.cz*1000.0;
	
	equa.cross(np, n);
	drect.cross(n, equa);
	equa.normalize();
	
	
	MyVector3D temp_V;
	temp_V = temp_V.rotate(equa, n, rad_fai);
	norm.normalize();
	n.normalize();
	
	MyVector3D v;
	v = v.rotate(norm, temp_V, rad_theta);
	printf("v0:%lf\n",v.length());
	
    v.x=Initpx;
    v.y=Initpy;
    v.z=Initpz;
	rover_v.setParameter(v.x, v.y, v.z);
	printf("initial V: %e %e %e %e\n",v.x,v.y,v.z,v.length());
    printf("mode is inlcude sun position calc.\n");
	o = rover_v.x;
	p = rover_v.y;
	q = rover_v.z;
	
	rover.setParameter(x/1000.0, y/1000.0, z/1000.0);
	gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
	sun_position = 	sunP.getSunPosition(0);
	//fprintf(outputfile, "%f\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\n",t,rover.x,rover.y,rover.z,rover.length(),o/1000.0,p/1000.0,q/1000.0,gravitation.u);
	fprintf(outputfile, "%lf\t%lf\t%d\n",h,limit,1);
	fprintf(outputfile, "%f\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%d\t%1.6E\t%1.6E\t%1.6E\n",
			t,rover.x,rover.y,rover.z,rover.length(),o/1000.0,p/1000.0,q/1000.0,object_angularV.x,object_angularV.y,object_angularV.z,gravitation.u,
			minerva.b_point[0][0],minerva.b_point[0][1],minerva.b_point[0][2],
			minerva.b_point[1][0],minerva.b_point[1][1],minerva.b_point[1][2],
			minerva.b_point[2][0],minerva.b_point[2][1],minerva.b_point[2][2],
			minerva.b_point[3][0],minerva.b_point[3][1],minerva.b_point[3][2],
			minerva.b_point[4][0],minerva.b_point[4][1],minerva.b_point[4][2],
			minerva.b_point[5][0],minerva.b_point[5][1],minerva.b_point[5][2],
			minerva.b_point[6][0],minerva.b_point[6][1],minerva.b_point[6][2],
			minerva.b_point[7][0],minerva.b_point[7][1],minerva.b_point[7][2],-1,sun_position[0],sun_position[1],sun_position[2]);
		t+=h;
    
    int count_times=0;
	while (TRUE) {
        printf("take %d times. \n",count_times);
        count_times++;
		pre_v = MyVector3D(v.x,v.y,v.z);
		pre_rover = MyVector3D(rover.x,rover.y,rover.z);
		minerva.setPreRoverPosition();
		
		yk1 = h*[self fy_t:t fy_p:p];
		xk1 = h*[self fx_t:t fx_o:o];
		zk1 = h*[self fz_t:t fz_q:q];
		pk1 = h*[self fp_x:x fp_y:y fp_z:z fp_o:o fp_p:p fp_q:q fp_t:t fp_w:w fp_gy:gvec.y*1000.0];
		ok1 = h*[self fo_x:x fo_y:y fo_z:z fo_o:o fo_p:p fo_q:q fo_t:t fo_w:w fo_gx:gvec.x*1000.0];
		qk1 = h*[self fq_x:x fq_y:y fq_z:z fq_o:o fq_p:p fq_q:q fq_t:t fq_w:w fq_gz:gvec.z*1000.0];
		
		yk2 = h*[self fy_t:t+h/2.0 fy_p:p+pk1/2.0];
		xk2 = h*[self fx_t:t+h/2.0 fx_o:o+ok1/2.0];
		zk2 = h*[self fz_t:t+h/2.0 fz_q:q+qk1/2.0];
		rover.x = (x+(xk1/2.0))/1000.0; rover.y = (y+(yk1/2.0))/1000.0; rover.z = (z+(zk1/2.0))/1000.0;
		gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
		pk2 = h*[self fp_x:x+xk1/2.0 fp_y:y+yk1/2.0 fp_z:z+zk1/2.0 fp_o:o+ok1/2.0 fp_p:p+pk1/2.0 fp_q:q+qk1/2.0 fp_t:t+h/2.0 fp_w:w fp_gy:gvec.y*1000.0];
		ok2 = h*[self fo_x:x+xk1/2.0 fo_y:y+yk1/2.0 fo_z:z+zk1/2.0 fo_o:o+ok1/2.0 fo_p:p+pk1/2.0 fo_q:q+qk1/2.0 fo_t:t+h/2.0 fo_w:w fo_gx:gvec.x*1000.0];
		qk2 = h*[self fq_x:x+xk1/2.0 fq_y:y+yk1/2.0 fq_z:z+zk1/2.0 fq_o:o+ok1/2.0 fq_p:p+pk1/2.0 fq_q:q+qk1/2.0 fq_t:t+h/2.0 fq_w:w fq_gz:gvec.z*1000.0];
		
		yk3 = h*[self fy_t:t+h/2.0 fy_p:p+pk2/2.0];
		xk3 = h*[self fx_t:t+h/2.0 fx_o:o+ok2/2.0];
		zk3 = h*[self fz_t:t+h/2.0 fz_q:q+qk2/2.0];
		rover.x = (x+(xk2/2.0))/1000.0; rover.y = (y+(yk2/2.0))/1000.0; rover.z = (z+(zk2/2.0))/1000.0;
		gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
		pk3 = h*[self fp_x:x+xk2/2.0 fp_y:y+yk2/2.0 fp_z:z+zk2/2.0 fp_o:o+ok2/2.0 fp_p:p+pk2/2.0 fp_q:q+qk2/2.0 fp_t:t+h/2.0 fp_w:w fp_gy:gvec.y*1000.0];
		ok3 = h*[self fo_x:x+xk2/2.0 fo_y:y+yk2/2.0 fo_z:z+zk2/2.0 fo_o:o+ok2/2.0 fo_p:p+pk2/2.0 fo_q:q+qk2/2.0 fo_t:t+h/2.0 fo_w:w fo_gx:gvec.x*1000.0];
		qk3 = h*[self fq_x:x+xk2/2.0 fq_y:y+yk2/2.0 fq_z:z+zk2/2.0 fq_o:o+ok2/2.0 fq_p:p+pk2/2.0 fq_q:q+qk2/2.0 fq_t:t+h/2.0 fq_w:w fq_gz:gvec.z*1000.0];
		
		yk4 = h*[self fy_t:t+h fy_p:p+pk3];
		xk4 = h*[self fx_t:t+h fx_o:o+ok3];
		zk4 = h*[self fz_t:t+h fz_q:q+qk3];
		rover.x = (x+xk3)/1000.0; rover.y = (y+yk3)/1000.0; rover.z = (z+zk3)/1000.0;
		
		gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
		pk4 = h*[self fp_x:x+xk3 fp_y:y+yk3 fp_z:z+zk3 fp_o:o+ok3 fp_p:p+pk3 fp_q:q+qk3 fp_t:t+h fp_w:w fp_gy:gvec.y*1000.0];
		ok4 = h*[self fo_x:x+xk3 fo_y:y+yk3 fo_z:z+zk3 fo_o:o+ok3 fo_p:p+pk3 fo_q:q+qk3 fo_t:t+h fo_w:w fo_gx:gvec.x*1000.0];
		qk4 = h*[self fq_x:x+xk3 fq_y:y+yk3 fq_z:z+zk3 fq_o:o+ok3 fq_p:p+pk3 fq_q:q+qk3 fq_t:t+h fq_w:w fq_gz:gvec.z*1000.0];
		
		yk = (yk1+2*yk2+2*yk3+yk4)/6.0;
		xk = (xk1+2*xk2+2*xk3+xk4)/6.0;
		zk = (zk1+2*zk2+2*zk3+zk4)/6.0;
		pk = (pk1+2*pk2+2*pk3+pk4)/6.0;
		ok = (ok1+2*ok2+2*ok3+ok4)/6.0;
		qk = (qk1+2*qk2+2*qk3+qk4)/6.0;
		
		y+=yk;
		x+=xk;
		z+=zk;
		p+=pk;
		o+=ok;
		q+=qk;
		
		rover.setParameter(x/1000.0, y/1000.0, z/1000.0);
		v.setParameter(o, p, q);
		minerva.moveRover(rover.x, rover.y, rover.z);
		minerva.rotateRover_vector(object_angularV,h);
		//minerva.rotateRover_vector(angularV_vector,h);
		//minerva.rotateRover(rw*h);
		gvec = gravitation.calculateG(rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
		
		//pre_laplas = laplas;
		laplas = gravitation.laplas;
		
		
		
		//レイトレース（形状付き）
		//立方体の８点、それぞれを見る
		double drx,dry,drz;
		double ja; //力積
		double min;
		int collisionPNum;
		int laplacianflag = 0;
		int flag = 0;
		MyVector3D r[8]; //重心から衝突点へのベクトル
		MyVector3D wr; //角速度ベクトルとrとの外積
		MyVector3D pa; //衝突点での合成速度
		MyVector3D rXn;//rと法線ベクトルとの外積
		MyVector3D iXrn; //慣性モーメントとrXnとの外積
		MyVector3D irnXr; //iXrnとrとの外積
		MyVector3D jN; //法線ベクトルに力積jをかけたもの
		MyVector3D rXjn; //rとjNとの外積
		MyVector3D near_pNormal;
		MyVector3D v_velocity[8];
		MyVector3D v_angvelocity[8];
		
		
		//各頂点が衝突していないか確認
		for (int i = 0; i < 8; i++) {
			ver_rover.setParameter(minerva.b_point[i][0], minerva.b_point[i][1],minerva.b_point[i][2]);
			ver_prerover.setParameter(minerva.preb_point[i][0], minerva.preb_point[i][1], minerva.preb_point[i][2]);
			gvec = v_gravitation.calculateG(ver_rover, vData, pData, commonF, numberOfvertices, numberOfplate, density);
			v_prelaplas[i] = v_laplas[i];
			v_laplas[i] = v_gravitation.laplas;
			
			//ラプラシアンでの前処理
			if (v_laplas[i] <= -6 || randflag[i] == 1) {
				if (v_laplas[i] < -12) {
					laplacianflag = 1;
					break;
				}
				randflag[i] = 1;
				
				RayTrace v_rayt;
				v_precolpId[i] = v_colpId[i];
				//レイトレースを行う
				v_colpId[i] = v_rayt.CollisionDetect(ver_prerover, ver_rover, dskfile);
				//printf("t i pid %lf %d %d\n",t,i,v_colpId[i]);
				CalLib clb;
				
				//if (v_precolpId[i] != -1 && v_colpId[i] == -1) {
				
				//光線（レイ）に当たっているポリゴンがあれば衝突
				if (v_colpId[i] > 0) {
					near_pNormal = clb.getNormalVector(v_colpId[i]-1, vData, pData);
					MyVector3D near_pCenter = clb.getGravityCenter(v_colpId[i]-1, vData, pData);
					
					//前のステップと現在のステップでの位置ベクトルとポリゴンの法線ベクトルとの内積をとる
					h1[i] = near_pNormal.dot(MyVector3D(ver_rover.x - near_pCenter.x, ver_rover.y - near_pCenter.y, ver_rover.z - near_pCenter.z));
					h2[i] = near_pNormal.dot(MyVector3D(ver_prerover.x - near_pCenter.x, ver_prerover.y - near_pCenter.y, ver_prerover.z - near_pCenter.z));
					//printf("pid h1 h2:%d %lf %lf\n",v_colpId[i],h1,h2);
					
					
					//符号が違うのであれば、現在のステップと前のステップの間に衝突をしていると判定
					if(h1[i]*h2[i] <= 0){
						min = h2[i];
						collisionPNum = i;
						printf("Step: %lf i:%d raytrace:%d %lf h1:%lf h2:%lf\n",t,i,v_colpId[i]-1,t,h1[i],h2[i]);
						//////////////////////////////////////////////////////////
						//衝突点を求める
						MyVector3D collisionPoint((ver_prerover.x*fabs(h1[i]) + ver_rover.x*fabs(h2[i]))/(fabs(h1[i])+fabs(h2[i])),
												  (ver_prerover.y*fabs(h1[i]) + ver_rover.y*fabs(h2[i]))/(fabs(h1[i])+fabs(h2[i])),
												  (ver_prerover.z*fabs(h1[i]) + ver_rover.z*fabs(h2[i]))/(fabs(h1[i])+fabs(h2[i])));
						
						if (flag == 0) {
							drx = minerva.b_point[i][0] - collisionPoint.x;
							dry = minerva.b_point[i][1] - collisionPoint.y;
							drz = minerva.b_point[i][2] - collisionPoint.z;
							rover.x = rover.x - drx;
							rover.y = rover.y - dry;
							rover.z = rover.z - drz;
							//minerva.moveRover((int)(cRposx*1e+6)*1e-6, (int)(cRposy*1e+6)*1e-6, (int)(cRposz*1e+6)*1e-6);
						}
						flag += 1;
						r[i].setParameter(collisionPoint.x - rover.x, collisionPoint.y - rover.y, collisionPoint.z - rover.z);
						wr.cross(angularV_vector, r[i]);
						pa.setParameter(v.x + wr.x, v.y + wr.y, v.z + wr.z);
						printf("i:%d pa:%e %e %e %e\n",i,pa.x,pa.y,pa.z,near_pNormal.dot(pa));
						
						rXn.cross(r[i], near_pNormal);
						iXrn.x = (minerva.rtX.x*minerva.rtX.x*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.x*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.x*minerva.Iinv.z)*rXn.x + 
						(minerva.rtX.x*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.y*minerva.Iinv.z)*rXn.y +
						(minerva.rtX.x*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.z*minerva.Iinv.z)*rXn.z;
						
						iXrn.y = (minerva.rtX.x*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.y*minerva.Iinv.z)*rXn.x +
						(minerva.rtX.y*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.y*minerva.Iinv.z)*rXn.y +
						(minerva.rtX.y*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.z*minerva.Iinv.z)*rXn.z;
						
						iXrn.z = (minerva.rtX.x*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.z*minerva.Iinv.z)*rXn.x +
						(minerva.rtX.y*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.z*minerva.Iinv.z)*rXn.y + 
						(minerva.rtX.z*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.z*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.z*minerva.rtZ.z*minerva.Iinv.z)*rXn.z;
						
						irnXr.cross(iXrn, r[i]);
						ja = -((1 + e)*(near_pNormal.dot(pa)))/((1/minerva.rmass)+near_pNormal.dot(irnXr));
						jN.setParameter(ja*near_pNormal.x, ja*near_pNormal.y, ja*near_pNormal.z);
						rXjn.cross(r[i], jN);
						
						v_velocity[i].setParameter(ja*near_pNormal.x/minerva.rmass, ja*near_pNormal.y/minerva.rmass, ja*near_pNormal.z/minerva.rmass);
						
						v_angvelocity[i].x = (pow(minerva.rtX.x,2)*minerva.Iinv.x + pow(minerva.rtY.x,2)*minerva.Iinv.y + pow(minerva.rtZ.x,2)*minerva.Iinv.z)*rXjn.x + 
						(minerva.rtX.x*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.y*minerva.Iinv.z)*rXjn.y +
						(minerva.rtX.x*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.z*minerva.Iinv.z)*rXjn.z;
						
						v_angvelocity[i].y = (minerva.rtX.x*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.y*minerva.Iinv.z)*rXjn.x +
						(minerva.rtX.y*minerva.rtX.y*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.y*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.y*minerva.Iinv.z)*rXjn.y +
						(minerva.rtX.y*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.z*minerva.Iinv.z)*rXjn.z;
						
						v_angvelocity[i].z = (minerva.rtX.x*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.x*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.x*minerva.rtZ.z*minerva.Iinv.z)*rXjn.x +
						(minerva.rtX.y*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.y*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.y*minerva.rtZ.z*minerva.Iinv.z)*rXjn.y + 
						(minerva.rtX.z*minerva.rtX.z*minerva.Iinv.x + minerva.rtY.z*minerva.rtY.z*minerva.Iinv.y + minerva.rtZ.z*minerva.rtZ.z*minerva.Iinv.z)*rXjn.z;
						
						printf("collision point: %e %e %e\n",collisionPoint.x,collisionPoint.y,collisionPoint.z);
						printf("rover: %e %e %e\n",rover.x,rover.y,rover.z);
						printf("J=%e\n",ja);
						//////////////////////////////////////////////////////////
						
												
					}//end of if(h1*h2 <= 0)
					else if(h1[i] < 0 && h2[i] < 0){
						printf("end h1<0 h2<0\n");
						break;
					}
					else {
						v_velocity[i].setParameter(0, 0, 0);
						v_angvelocity[i].setParameter(0, 0, 0);
						h1[i] = 0;
						h2[i] = 0;
					}
				}//end of if (v_colpId[i] > 0)
			}//end of if(v_laplas[i] <= -6....	
		}// end of for (int i = 0; i < 8; i++)
		
		
		//衝突点があったら
		if (flag != 0) {
			printf("prev: %e %e %e %e\n",v.x,v.y,v.z,v.length());
			for (int j = 0;  j < 8; j ++) {
				//printf("min %lf h2 : %lf\n",min,h2[j]);
				
				if (h2[j] != 0 && h2[j] <= min) {
					min = h2[j];
					collisionPNum = j;
					collisionId = v_colpId[j];
					//printf("collision Id : %d\n",collisionId);
					
				}
				randflag[j] = 0;
			}
			
			v.x += v_velocity[collisionPNum].x;
			v.y += v_velocity[collisionPNum].y;
			v.z += v_velocity[collisionPNum].z;
			angularV_vector.x += v_angvelocity[collisionPNum].x;
			angularV_vector.y += v_angvelocity[collisionPNum].y;
			angularV_vector.z += v_angvelocity[collisionPNum].z;
			printf("i:%d v: %e %e %e L:%e\n",collisionPNum,v_velocity[collisionPNum].x,v_velocity[collisionPNum].y,v_velocity[collisionPNum].z,v_velocity[collisionPNum].length());
			MyVector3D awr;
			MyVector3D apa;
			awr.cross(angularV_vector, r[collisionPNum]);
			apa.setParameter(v.x+awr.x,v.y+awr.y,v.z+awr.z);
			printf("after p: %e %e %e %e\n",apa.x,apa.y,apa.z,near_pNormal.dot(apa));
			o = v.x;
			p = v.y;
			q = v.z;
			printf("prec: %e %e %e\n",minerva.cx,minerva.cy,minerva.cz);
			minerva.moveRover(rover.x, rover.y, rover.z);
			//角速度ベクトルが変化したのでまた、座標変換したベクトルを定義
			detA = minerva.rtX.x*minerva.rtY.y*minerva.rtZ.z + minerva.rtX.y*minerva.rtY.z*minerva.rtZ.x + minerva.rtX.z*minerva.rtY.x*minerva.rtZ.y - minerva.rtX.x*minerva.rtY.z*minerva.rtZ.y - minerva.rtX.z*minerva.rtY.y*minerva.rtZ.x - minerva.rtX.y*minerva.rtY.x*minerva.rtZ.z;
			object_angularV.setParameter(((minerva.rtY.y*minerva.rtZ.z-minerva.rtZ.y*minerva.rtY.z)/detA*angularV_vector.x) + ((minerva.rtZ.x*minerva.rtY.z-minerva.rtY.x*minerva.rtZ.z)/detA*angularV_vector.y) + ((minerva.rtY.x*minerva.rtZ.y-minerva.rtZ.x*minerva.rtY.y)/detA*angularV_vector.z),
										 ((minerva.rtZ.y*minerva.rtX.z-minerva.rtX.y*minerva.rtZ.z)/detA*angularV_vector.x) + ((minerva.rtX.x*minerva.rtZ.z-minerva.rtZ.x*minerva.rtX.z)/detA*angularV_vector.y) + ((minerva.rtZ.x*minerva.rtX.y-minerva.rtX.x*minerva.rtZ.y)/detA*angularV_vector.z),
										 ((minerva.rtX.y*minerva.rtY.z-minerva.rtY.y*minerva.rtX.z)/detA*angularV_vector.x) + ((minerva.rtY.x*minerva.rtX.z-minerva.rtX.x*minerva.rtY.z)/detA*angularV_vector.y) + ((minerva.rtX.x*minerva.rtY.y-minerva.rtY.x*minerva.rtX.y)/detA*angularV_vector.z));
			printf("c: %e %e %e\n",minerva.cx,minerva.cy,minerva.cz);
			printf("v: %e %e %e %e\n",v.x,v.y,v.z,v.length());
			printf("tw: %e %e %e %e\n\n",angularV_vector.x,angularV_vector.y,angularV_vector.z,angularV_vector.length()*180.0/M_PI);
			if (near_pNormal.dot(apa) < 1e-3) {
				printf("break\n");
				break;
			}
			
		}
		
		for (int j = 0 ; j < 8 ; j++) {
			h1[j] = 0;
			h2[j] = 0;
		}
		//レイトレース終了
		
		if (t == 0) {
			//for (int i = 0 ; i < ppp.size(); i++) {
			//printf("%d\n",(*ppp).size());
			//}
		}
		//t+=h;
		
		
		
		//if(t > limit) break;
		if (v.length() < 1e-3) {
			break;
		}
		sun_position = sunP.getSunPosition(t);
				fprintf(outputfile, "%f\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%1.6E\t%d\t%1.6E\t%1.6E\t%1.6E\n",
				t,rover.x,rover.y,rover.z,rover.length(),o/1000.0,p/1000.0,q/1000.0,object_angularV.x,object_angularV.y,object_angularV.z,gravitation.u,
				minerva.b_point[0][0],minerva.b_point[0][1],minerva.b_point[0][2],
				minerva.b_point[1][0],minerva.b_point[1][1],minerva.b_point[1][2],
				minerva.b_point[2][0],minerva.b_point[2][1],minerva.b_point[2][2],
				minerva.b_point[3][0],minerva.b_point[3][1],minerva.b_point[3][2],
				minerva.b_point[4][0],minerva.b_point[4][1],minerva.b_point[4][2],
				minerva.b_point[5][0],minerva.b_point[5][1],minerva.b_point[5][2],
				minerva.b_point[6][0],minerva.b_point[6][1],minerva.b_point[6][2],
				minerva.b_point[7][0],minerva.b_point[7][1],minerva.b_point[7][2],collisionId,sun_position[0],sun_position[1],sun_position[2]);
		collisionId = -1;
				
		
		/* if(laplas < -12)
		 {
		 break;
		 }*/
		 
		t += h;
		
		if( t > limit ) break;
		/*
		 if (cfound != 0) {
		 break;
		 }
		 */
	}
	
	fclose(outputfile);
	fclose(outputfile_rover);
	//cfound = 0;
}//日照を含めた計算終了

//do/dt
-(double)fo_x:(double)x fo_y:(double)y fo_z:(double)z fo_o:(double)o fo_p:(double)p fo_q:(double)q fo_t:(double)t fo_w:(double)w fo_gx:(double)gx
{
	return w*w*x+gx+2.0*w*p;
}

//dp/dt
-(double)fp_x:(double)x fp_y:(double)y fp_z:(double)z fp_o:(double)o fp_p:(double)p fp_q:(double)q fp_t:(double)t fp_w:(double)w fp_gy:(double)gy
{
	return w*w*y+gy-2.0*w*o;
}

//dq/dt
-(double)fq_x:(double)x fq_y:(double)y fq_z:(double)z fq_o:(double)o fq_p:(double)p fq_q:(double)q fq_t:(double)t fq_w:(double)w fq_gz:(double)gz
{
	return gz;
}

//dx/dt
-(double)fx_t:(double)t fx_o:(double)o
{
	return o;
}

//dy/dt
-(double)fy_t:(double)t fy_p:(double)p
{
	return p;
}

//dz/dt
-(double)fz_t:(double)t fz_q:(double)q
{
	return q;
}

-(double)toDegrees:(double)radian
{

	return radian*180.0/M_PI;
	
}

-(double)toRadian:(double)degrees
{

	return degrees*M_PI/180.0;
}





-(void)setAreaGroup:(vector<int>*)tppp ppm:(vector<int>*)tppm pmp:(vector<int>*)tpmp mpp:(vector<int>*)tmpp pmm:(vector<int>*)tpmm mpm:(vector<int>*)tmpm mmp:(vector<int>*)tmmp mmm:(vector<int>*)tmmm
{
	[self setPpp:tppp];
	[self setPpm:tppm];
	[self setPmp:tpmp];
	[self setMpp:tmpp];
	[self setPmm:tpmm];
	[self setMpm:tmpm];
	[self setMmp:tmmp];
	[self setMmm:tmmm];
	clmth.setArea(tppp, tppm, tpmp, tmpp, tpmm, tmpm, tmmp, tmmm);
}



@end
