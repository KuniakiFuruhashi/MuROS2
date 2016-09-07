/*
 *  Rover.cpp
 *  RoverSimulator20120621
 *
 *  Created by Toshihiro Harada on 12/06/27.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "Rover.h"

Rover::Rover(void)
{
	b_point = (double**)malloc(sizeof(double*)*8);
	preb_point = (double**)malloc(sizeof(double*)*8);
	original_rover = (double**)malloc(sizeof(double*)*8);
	for (int i = 0; i < 8; i++) {
		b_point[i] = (double*)malloc(sizeof(double)*3);
		preb_point[i] = (double*)malloc(sizeof(double)*3);
		original_rover[i] = (double*)malloc(sizeof(double)*3);
	}
}

Rover::Rover(double w, double x, double y, double z, double m)
{
	MyVector3D p0;
	MyVector3D p1;
	MyVector3D p2;
	MyVector3D v1;
	MyVector3D v2;
	double m_rsize;
	rt[0][0] = 1; rt[0][1] = 0; rt[0][2] = 0; //Xx Yx Zx 
	rt[1][0] = 0; rt[1][1] = 1; rt[1][2] = 0; //Xy Yy Zy
	rt[2][0] = 0; rt[2][1] = 0; rt[2][2] = 0; //Xz Yz Zz
	
	rtX.setParameter(1, 0, 0); // Xx Xy Xz
	rtY.setParameter(0, 1, 0); // Yx Yy Yz
	rtZ.setParameter(0, 0, 1); // Zx Zy Zz
	
	rsize = w;
	rmass = m;
	b_point = (double**)malloc(sizeof(double*)*8);
	for (int i = 0; i < 8; i++) {
		b_point[i] = (double*)malloc(sizeof(double)*3);
	}
	preb_point = (double**)malloc(sizeof(double*)*8);
	for (int i = 0; i < 8; i++) {
		preb_point[i] = (double*)malloc(sizeof(double)*3);
	}
	original_rover = (double**)malloc(sizeof(double*)*8);
	for (int i = 0; i < 8 ; i++) {
		original_rover[i] = (double*)malloc(sizeof(double)*3);
	}
	b_index = (int**)malloc(sizeof(int*)*6);
	for (int i = 0 ; i < 6; i++) {
		b_index[i] = (int*)malloc(sizeof(int)*4);
	}
	
	cx = x;
	cy = y;
	cz = z;
	
	n.cross(rNVec, rDVec);
	n.normalize();
	/*
	    z  y
	    | /
	    |/
		c---x
	 
			A------D
		   /|     /|
		  B------C |
		  | E----|-H
	      |/     |/
	      F------G 
	
	*/
	b_point[0][0] = cx-w/2.0; b_point[0][1] = cy+w/2.0; b_point[0][2] = cz+w/2.0;//A
	b_point[1][0] = cx-w/2.0; b_point[1][1] = cy-w/2.0; b_point[1][2] = cz+w/2.0;//B
	b_point[2][0] = cx+w/2.0; b_point[2][1] = cy-w/2.0; b_point[2][2] = cz+w/2.0;//C
	b_point[3][0] = cx+w/2.0; b_point[3][1] = cy+w/2.0; b_point[3][2] = cz+w/2.0;//D
	b_point[4][0] = cx-w/2.0; b_point[4][1] = cy+w/2.0; b_point[4][2] = cz-w/2.0;//E
	b_point[5][0] = cx-w/2.0; b_point[5][1] = cy-w/2.0; b_point[5][2] = cz-w/2.0;//F
	b_point[6][0] = cx+w/2.0; b_point[6][1] = cy-w/2.0; b_point[6][2] = cz-w/2.0;//G
	b_point[7][0] = cx+w/2.0; b_point[7][1] = cy+w/2.0; b_point[7][2] = cz-w/2.0;//H

	preb_point[0][0] = cx-w/2.0; preb_point[0][1] = cy+w/2.0; preb_point[0][2] = cz+w/2.0;//A
	preb_point[1][0] = cx-w/2.0; preb_point[1][1] = cy-w/2.0; preb_point[1][2] = cz+w/2.0;//B
	preb_point[2][0] = cx+w/2.0; preb_point[2][1] = cy-w/2.0; preb_point[2][2] = cz+w/2.0;//C
	preb_point[3][0] = cx+w/2.0; preb_point[3][1] = cy+w/2.0; preb_point[3][2] = cz+w/2.0;//D
	preb_point[4][0] = cx-w/2.0; preb_point[4][1] = cy+w/2.0; preb_point[4][2] = cz-w/2.0;//E
	preb_point[5][0] = cx-w/2.0; preb_point[5][1] = cy-w/2.0; preb_point[5][2] = cz-w/2.0;//F
	preb_point[6][0] = cx+w/2.0; preb_point[6][1] = cy-w/2.0; preb_point[6][2] = cz-w/2.0;//G
	preb_point[7][0] = cx+w/2.0; preb_point[7][1] = cy+w/2.0; preb_point[7][2] = cz-w/2.0;//H
	
	original_rover[0][0] = -w/2.0; original_rover[0][1] = w/2.0; original_rover[0][2] = w/2.0;//A
	original_rover[1][0] = -w/2.0; original_rover[1][1] = -w/2.0; original_rover[1][2] = w/2.0;//B
	original_rover[2][0] = w/2.0; original_rover[2][1] = -w/2.0; original_rover[2][2] = w/2.0;//C
	original_rover[3][0] = w/2.0; original_rover[3][1] = w/2.0; original_rover[3][2] = w/2.0;//D
	original_rover[4][0] = -w/2.0; original_rover[4][1] = w/2.0; original_rover[4][2] = -w/2.0;//E
	original_rover[5][0] = -w/2.0; original_rover[5][1] = -w/2.0; original_rover[5][2] = -w/2.0;//F
	original_rover[6][0] = w/2.0; original_rover[6][1] = -w/2.0; original_rover[6][2] = -w/2.0;//G
	original_rover[7][0] = w/2.0; original_rover[7][1] = w/2.0; original_rover[7][2] = -w/2.0;//H
	
	b_index[0][0] = 0; b_index[0][1] = 1; b_index[0][2] = 2; b_index[0][3] = 3;
	b_index[1][0] = 0; b_index[1][1] = 4; b_index[1][2] = 5; b_index[1][3] = 1;
	b_index[2][0] = 1; b_index[2][1] = 5; b_index[2][2] = 6; b_index[2][3] = 2;
	b_index[3][0] = 2; b_index[3][1] = 6; b_index[3][2] = 7; b_index[3][3] = 3;
	b_index[4][0] = 3; b_index[4][1] = 7; b_index[4][2] = 4; b_index[4][3] = 0;
	b_index[5][0] = 5; b_index[5][1] = 4; b_index[5][2] = 7; b_index[5][3] = 6;

	p0.setParameter(b_point[b_index[0][0]][0], b_point[b_index[0][0]][1], b_point[b_index[0][0]][2]);
	p1.setParameter(b_point[b_index[0][1]][0], b_point[b_index[0][1]][1], b_point[b_index[0][1]][2]);
	p2.setParameter(b_point[b_index[0][2]][0], b_point[b_index[0][2]][1], b_point[b_index[0][2]][2]);
	v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
	v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
	
	rNVec.cross(v1, v2);
	rNVec.normalize();
	
	p0.setParameter(b_point[b_index[4][0]][0], b_point[b_index[4][0]][1], b_point[b_index[4][0]][2]);
	p1.setParameter(b_point[b_index[4][1]][0], b_point[b_index[4][1]][1], b_point[b_index[4][1]][2]);
	p2.setParameter(b_point[b_index[4][2]][0], b_point[b_index[4][2]][1], b_point[b_index[4][2]][2]);
	v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
	v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
	rDVec.cross(v1, v2);
	rDVec.normalize();

	//printf("angle1: %lf\n",rNVec.angleOfVector(rDVec)*180.0/M_PI);
	//慣性モーメントの定義
	m_rsize = rsize*100;
	I.setParameter((rmass*(m_rsize*m_rsize+m_rsize*m_rsize)/12.0),(rmass*(m_rsize*m_rsize+m_rsize*m_rsize)/12.0), (rmass*(m_rsize*m_rsize+m_rsize*m_rsize)/12.0));
	Iinv.setParameter(1.0/I.x, 1.0/I.y, 1.0/I.z);

}

//ポリゴンの法線ベクトル、ポリゴンの重心、回転軸への方位ベクトル、方位ベクトルから何度傾いているか（度）
void Rover::setAttiRover(MyVector3D pNVec, MyVector3D pCVec, MyVector3D directionVec, double directionAngle)
{
	
	double radDirectAngle = directionAngle*M_PI/180.0;
	MyVector3D b_cVec;
	//n.cross(pNVec, rNVec);
	n.cross(pNVec, rNVec);
	//n.cross(rNVec, pNVec);
	//n.cross(rDVec, rNVec);
	n.normalize();
	
	double nAngle = rNVec.angleOfVector(pNVec);
	//ポリゴンの法線ベクトルにローバを合わせる
	rNVec = rNVec.rotate(n, rNVec, nAngle);//ローバの垂直ベクトルを回転
	rDVec = rDVec.rotate(n, rDVec, nAngle);//ローバの方向ベクトルを回転
/*
	for (int i = 0 ;  i < 8; i++) {
		b_vec.setParameter(b_point[i][0], b_point[i][1], b_point[i][2]);
		b_cVec.setParameter(b_vec.x - pCVec.x, b_vec.y - pCVec.y, b_vec.z - pCVec.z);
		b_cVec = b_cVec.rotate(n, b_cVec, nAngle);
		b_point[i][0] = b_cVec.x + pCVec.x; b_point[i][1] = b_cVec.y + pCVec.y; b_point[i][2] = b_cVec.z +pCVec.z;
	}
*/	
	//方位角にローバ正面を合わせる
	double dAngle = directionVec.angleOfVector(rDVec);
    printf("\n dAngle is %lf \n",dAngle);
	n.cross(rDVec, directionVec);
	n.normalize();
	printf("prev angle : %lf\n",directionVec.angleOfVector(rDVec.rotate(n, rDVec, dAngle))*180.0/M_PI);
	if (directionVec.angleOfVector(rDVec.rotate(n, rDVec, dAngle)) == 0) {
		rDVec = rDVec.rotate(n, rDVec, dAngle);
	}
	else {
		dAngle = 2*M_PI - dAngle;
		rDVec = rDVec.rotate(n, rDVec, dAngle);
	}

	printf("after angle : %lf\n",directionVec.angleOfVector(rDVec)*180.0/M_PI);
	//rDVec = rDVec.rotate(n, rDVec, radDirectAngle);
	printf("dAngle : %lf\n",dAngle*180.0/M_PI);
	/*
	for (int i = 0 ;  i < 8; i++) {
		b_vec.setParameter(b_point[i][0], b_point[i][1], b_point[i][2]);
		b_cVec.setParameter(b_vec.x - pCVec.x, b_vec.y - pCVec.y, b_vec.z - pCVec.z);
		b_cVec = b_cVec.rotate(n, b_cVec, dAngle);
		b_point[i][0] = b_cVec.x + pCVec.x; b_point[i][1] = b_cVec.y + pCVec.y; b_point[i][2] = b_cVec.z +pCVec.z;
	}
	*/
	//方位角からの変位を加える
	rDVec = rDVec.rotate(rNVec, rDVec, radDirectAngle);
	/*
	for (int i = 0 ;  i < 8; i++) {
		b_vec.setParameter(b_point[i][0], b_point[i][1], b_point[i][2]);
		b_cVec.setParameter(b_vec.x - pCVec.x, b_vec.y - pCVec.y, b_vec.z - pCVec.z);
		b_cVec = b_cVec.rotate(rNVec, b_cVec, radDirectAngle);
		b_point[i][0] = b_cVec.x + pCVec.x; b_point[i][1] = b_cVec.y + pCVec.y; b_point[i][2] = b_cVec.z +pCVec.z;
	}
	*/
	//浮かせる
	cx = cx + (rNVec.x * (rsize/2));
	cy = cy + (rNVec.y * (rsize/2));
	cz = cz + (rNVec.z * (rsize/2));
	printf("RSize:%e\n",rNVec.length());
	/*
	for (int i = 0 ;  i< 8 ; i++) {
		b_point[i][0] = b_point[i][0]+(rNVec.x * (rsize/2));
		b_point[i][1] = b_point[i][1]+(rNVec.y * (rsize/2));
		b_point[i][2] = b_point[i][2]+(rNVec.z * (rsize/2));
	}
	*/
	rtX.setParameter(rDVec.x, rDVec.y, rDVec.z);
	rtX.normalize();
	rtY.setParameter(rNVec.x, rNVec.y, rNVec.z);
	rtY.normalize();
	rtZ.cross(rtX, rtY);
	rtZ.normalize();
	
	//rtX.setParameter((int)(rtX.x*1e+6)*1e-6,(int)(rtX.y*1e+6)*1e-6,(int)(rtX.z*1e+6)*1e-6);
	//rtY.setParameter((int)(rtY.x*1e+6)*1e-6,(int)(rtY.y*1e+6)*1e-6,(int)(rtY.z*1e+6)*1e-6);
	//rtZ.setParameter((int)(rtZ.x*1e+6)*1e-6,(int)(rtZ.y*1e+6)*1e-6,(int)(rtZ.z*1e+6)*1e-6);

	for (int i = 0 ;  i < 8; i++) {
		b_point[i][0] = (original_rover[i][0]*rtX.x + original_rover[i][1]*rtY.x + original_rover[i][2]*rtZ.x) + cx;
		b_point[i][1] = (original_rover[i][0]*rtX.y + original_rover[i][1]*rtY.y + original_rover[i][2]*rtZ.y) + cy;
		b_point[i][2] = (original_rover[i][0]*rtX.z + original_rover[i][1]*rtY.z + original_rover[i][2]*rtZ.z) + cz;
	}
	
	
	printf("angle1: %lf\n",rtX.angleOfVector(rtY)*180.0/M_PI);
	printf("rtX: %e %e %e\n",rtX.x,rtX.y,rtX.z);
	printf("rtY: %e %e %e\n",rtY.x,rtY.y,rtY.z);
	printf("rtZ: %e %e %e\n",rtZ.x,rtZ.y,rtZ.z);

	
}

//ローバ移動(移動先重心座標)
void Rover::moveRover(double x, double y, double z)
{
	double dx,dy,dz;
	dx = x - cx; dy = y - cy; dz = z - cz;//移動先座標と現在の重心の差分を取る
	
	//移動
	for(int i = 0 ; i < 8 ; i++)
	{
		//差分を各頂点に加えることで移動させる
		b_point[i][0] += dx; b_point[i][1] += dy; b_point[i][2] += dz;
	}
	//移動後の重心を更新
	cx = x;
	cy = y;
	cz = z;
}

//ローバ回転させる(ラジアン,回転軸)
void Rover::rotateRover_axis(double rAngle, MyVector3D n)
{
	//double rRadAngle = rAngle*M_PI/180.0; //ラジアンに変換
	double rRadAngle = rAngle;
	MyVector3D b_cVec;
	//n.cross(rNVec, rDVec); //回転軸を決定
	//n.normalize();
	rNVec = rNVec.rotate(n, rNVec, rRadAngle);//ローバの垂直ベクトルを回転
	rDVec = rDVec.rotate(n, rDVec, rRadAngle);//ローバの方向ベクトルを回転
	rtX = rtX.rotate(n, rtX, rRadAngle);
	rtY = rtY.rotate(n, rtY, rRadAngle);
	rtZ = rtZ.rotate(n, rtZ, rRadAngle);
	//nを軸にし、重心から各頂点へのベクトルを回転
	for (int i = 0 ;  i < 8; i++) {
		//b_vec.setParameter(b_point[i][0], b_point[i][1], b_point[i][2]);
		//b_cVec.setParameter(b_vec.x - cx, b_vec.y - cy, b_vec.z - cz);
		//b_cVec = b_cVec.rotate(rtX, b_cVec, rRadAngle);
		//b_point[i][0] = b_cVec.x + cx; b_point[i][1] = b_cVec.y + cy; b_point[i][2] = b_cVec.z + cz;
		
		b_point[i][0] = (original_rover[i][0]*rtX.x + original_rover[i][1]*rtY.x + original_rover[i][2]*rtZ.x) + cx;
		b_point[i][1] = (original_rover[i][0]*rtX.y + original_rover[i][1]*rtY.y + original_rover[i][2]*rtZ.y) + cy;
		b_point[i][2] = (original_rover[i][0]*rtX.z + original_rover[i][1]*rtY.z + original_rover[i][2]*rtZ.z) + cz;
		b_point[i][0] = (int)(b_point[i][0]*1e+6)*1e-6;
		b_point[i][1] = (int)(b_point[i][1]*1e+6)*1e-6;
		b_point[i][2] = (int)(b_point[i][2]*1e+6)*1e-6;
		
		
	}
	
}

//ローバーを回転させる（角速度ベクトル）
void Rover::rotateRover_vector(MyVector3D wt,double h)
{
	MyVector3D tempX(rtX.x, rtX.y, rtX.z);
	MyVector3D tempY(rtY.x, rtY.y, rtY.z);
	MyVector3D tempZ(rtZ.x, rtZ.y, rtZ.z);
	MyVector3D temp;
	MyVector3D b_cVec;
	MyVector3D object_wt;
	MyVector3D temp_wt;
	
	///*
	MyQuaternion qr;
	MyQuaternion tqr;
	MyQuaternion rXw;
	MyQuaternion nextQR;
	MyQuaternion qw(wt.x, wt.y, wt.z, 0);

	
	qr = transformRotMatToQuaternion(tempX, tempY, tempZ);
	
	tqr.setParameter(qr.x/2.0, qr.y/2.0, qr.z/2.0, qr.w/2.0);
	rXw.multi(tqr, qw);
	rXw.setParameter(rXw.x*h, rXw.y*h, rXw.z*h, rXw.w*h);
	
	
	
	nextQR.plus(qr, rXw);
	transformQuaternionToRotMat(rtX, rtY, rtZ, nextQR);
	//*/
	/*
	 //printf("wt:%e\n",wt.length());
	 //printf("rotate Rorver : %e %e %e\n",wt.x,wt.y,wt.z);
	 
	 //temp.setParameter((int)(wt.y*tempX.z*1e+6)*1e-6 - (int)(tempX.y*wt.z*1e+6)*1e-6 , (int)(tempX.x*wt.z*1e+6)*1e-6 - (int)(wt.x*tempX.z*1e+6)*1e-6, (int)(wt.x*tempX.y*1e+6)*1e-6 - (int)(tempX.x*wt.y*1e+6)*1e-6);
	 temp.cross(wt,tempX);
	 rtX.setParameter(temp.x*h + rtX.x, temp.y*h + rtX.y, temp.z*h + rtX.z);
	 
	 //temp.setParameter(wt.y*tempY.z - tempY.y*wt.z , tempY.x*wt.z - wt.x*tempY.z, wt.x*tempY.y - tempY.x*wt.y);
	 //temp.setParameter((int)(wt.y*tempY.z*1e+6)*1e-6 - (int)(tempY.y*wt.z*1e+6)*1e-6 , (int)(tempY.x*wt.z*1e+6)*1e-6 - (int)(wt.x*tempY.z*1e+6)*1e-6, (int)(wt.x*tempY.y*1e+6)*1e-6 - (int)(tempY.x*wt.y*1e+6)*1e-6);
	 temp.cross(wt,tempY);
	 rtY.setParameter(temp.x*h + rtY.x, temp.y*h + rtY.y, temp.z*h + rtY.z);
	 
	 //temp.setParameter(wt.y*tempZ.z - tempZ.y*wt.z , tempZ.x*wt.z - wt.x*tempZ.z, wt.x*tempZ.y - tempZ.x*wt.y);
	 //temp.setParameter((int)(wt.y*tempZ.z*1e+6)*1e-6 - (int)(tempZ.y*wt.z*1e+6)*1e-6 , (int)(tempZ.x*wt.z*1e+6)*1e-6 - (int)(wt.x*tempZ.z*1e+6)*1e-6, (int)(wt.x*tempZ.y*1e+6)*1e-6 - (int)(tempZ.x*wt.y*1e+6)*1e-6);
	 temp.cross(wt, tempZ);
	 rtZ.setParameter(temp.x*h + rtZ.x, temp.y*h + rtZ.y, temp.z*h + rtZ.z);
	*/
	
	
	/*
	 printf("angle1: %lf\n",rtZ.angleOfVector(rtX)*180.0/M_PI);
	 printf("angle2: %lf\n",rtZ.angleOfVector(rtY)*180.0/M_PI);
	 printf("inter: %e %e %e\n",wt.y*tempZ.z-tempZ.y*wt.z,tempZ.x*wt.z-wt.x*tempZ.z,wt.x*tempZ.y-tempZ.x*wt.y);
	 */
	
	
	rtX.normalize();
	rtY.normalize();
	rtZ.normalize();
	//printf("angle1: %lf\n",rtZ.angleOfVector(rtX)*180.0/M_PI);
	//printf("angle2: %lf\n",rtZ.angleOfVector(rtY)*180.0/M_PI);
	for (int i = 0 ;  i < 8; i++) {
		
		b_point[i][0] = (original_rover[i][0]*rtX.x + original_rover[i][1]*rtY.x + original_rover[i][2]*rtZ.x) + cx;
		b_point[i][1] = (original_rover[i][0]*rtX.y + original_rover[i][1]*rtY.y + original_rover[i][2]*rtZ.y) + cy;
		b_point[i][2] = (original_rover[i][0]*rtX.z + original_rover[i][1]*rtY.z + original_rover[i][2]*rtZ.z) + cz;
		//b_point[i][0] = (int)(b_point[i][0]*1e+6)*1e-6;
		//b_point[i][1] = (int)(b_point[i][1]*1e+6)*1e-6;
		//b_point[i][2] = (int)(b_point[i][2]*1e+6)*1e-6;
	}
}

void Rover::setPreRoverPosition(){
	for (int i = 0 ;  i < 8; i++) {
		preb_point[i][0] = b_point[i][0];
		preb_point[i][1] = b_point[i][1];
		preb_point[i][2] = b_point[i][2];
	}		
}

//クォータニオンから行列への変換
void Rover::transformQuaternionToRotMat(MyVector3D& x, MyVector3D& y, MyVector3D& z, MyQuaternion q)
{
	
	
	x.x = 1.0 - 2.0 * q.y * q.y - 2.0 * q.z * q.z;
    x.y = 2.0 * q.x * q.y + 2.0 * q.w * q.z;
    x.z = 2.0 * q.x * q.z - 2.0 * q.w * q.y;
	
    y.x = 2.0 * q.x * q.y - 2.0 * q.w * q.z;
    y.y = 1.0 - 2.0 * q.x * q.x - 2.0 * q.z * q.z;
    y.z = 2.0 * q.y * q.z + 2.0 * q.w * q.x;
	
    z.x = 2.0 * q.x * q.z + 2.0 * q.w * q.y;
    z.y = 2.0 * q.y * q.z - 2.0 * q.w * q.x;
    z.z = 1.0 - 2.0 * q.x * q.x - 2.0 * q.y * q.y;
}

//行列からクォータニオンへの変換
MyQuaternion Rover::transformRotMatToQuaternion(MyVector3D x, MyVector3D y, MyVector3D z)
{
	double m11 = x.x; double m12 = x.y; double m13 = x.z;
	double m21 = y.x; double m22 = y.y; double m23 = y.z;
	double m31 = z.x; double m32 = z.y; double m33 = z.z;
	
	//最大成分を検索
	double elem[4]; // 0:x, 1:y, 2:z, 3:w
	elem[0] = m11 - m22 - m33 + 1.0;
	elem[1] = -m11 + m22 - m33 + 1.0;
	elem[2] = -m11 - m22 + m33 + 1.0;
	elem[3] = m11 + m22 + m33 + 1.0;
	
	unsigned biggestIndex = 0;
	
	for ( int i = 1; i < 4; i++ ) {
        if ( elem[i] > elem[biggestIndex] )
            biggestIndex = i;
    }
	
	
    if ( elem[biggestIndex] < 0.0f )
		printf("false in quaternion!\n"); ; // 引数の行列に間違いあり！
	
    // 最大要素の値を算出
    double q[4];
    double v = sqrt( elem[biggestIndex] ) * 0.5;
    q[biggestIndex] = v;
    double mult = 0.25 / v;
	
    switch ( biggestIndex ) {
		case 0: // x
			q[1] = (m12 + m21) * mult;
			q[2] = (m31 + m13) * mult;
			q[3] = (m23 - m32) * mult;
			break;
		case 1: // y
			q[0] = (m12 + m21) * mult;
			q[2] = (m23 + m32) * mult;
			q[3] = (m31 - m13) * mult;
			break;
		case 2: // z
			q[0] = (m31 + m13) * mult;
			q[1] = (m23 + m32) * mult;
			q[3] = (m12 - m21) * mult;
			break;
		case 3: // w
			q[0] = (m23 - m32) * mult;
			q[1] = (m31 - m13) * mult;
			q[2] = (m12 - m21) * mult;
			break;
    }
	
	MyQuaternion rq(q[0],q[1],q[2],q[3]);
	
	
	return rq;
}