/*
 *  GravitationCalculator.cpp
 *  TestOpenGL
 *
 *  Created by Toshihiro Harada on 12/05/29.
 *  Copyright 2012 __MyCompanyName__. All rights reserved.
 *
 */

#include "GravitationCalculator.h"


//コンストラクタ
GravitationCalculator::GravitationCalculator(void){
	laplas = 0;	
}


//小惑星固定座標系
//重力ポテンシャル計算用関数　引数リスト(重力ポテンシャルを求める位置、対象の形状モデルの頂点データ、対象の形状モデルの頂点組み合わせデータ、頂点数、ポリゴン数、密度) 
MyVector3D GravitationCalculator::calculateG(MyVector3D rover,double** data,int** platedata,int** commonF,int nV,int nP,double density){
	
	
	
	MyVector3D nu;
	MyVector3D fp;//field point
	MyVector3D mp;//ポリゴン重心
	MyVector3D nf;//面の法線
	MyVector3D rf;//field point から面へのベクトル
	MyVector3D re;//field point から辺へのベクトル
	MyVector3D nfb;//辺を共有している面の法線ベクトル
	MyVector3D n12;//面の平面ベクトル
	MyVector3D n21;//辺を共有している面の平面ベクトル
	MyVector3D nface;//ナブラuを求める際のface部分
	MyVector3D nedges;//ナブラuを求める際のedge部分
	MyVector3D ri;
	MyVector3D rj;
	MyVector3D rk;
	MyVector3D cross;
	MyVector3D pxff;
	MyVector3D pyff;
	MyVector3D pzff;
	MyVector3D ffpx;
	MyVector3D ffpy;
	MyVector3D ffpz;
	MyVector3D rfff;
	MyVector3D ffRf;
	MyVector3D ei;
	MyVector3D ej;
	MyVector3D eij;
	MyVector3D eji;
	MyVector3D vi;
	MyVector3D vj;
	MyVector3D pxee;
	MyVector3D pyee;
	MyVector3D pzee;
	MyVector3D eepx;
	MyVector3D eepy;
	MyVector3D eepz;
	MyVector3D reee;
	MyVector3D eeRe;
	
	double G = 6.673e-20; //万有引力定数
	
	int i;
	int flag = 0;
	int p,q;
	int indexOfei;
	int indexOfej;
	double face = 0;//faceのポテンシャル
	double edges = 0;//edgeのポテンシャル
	double wf = 0;//wf
	double le = 0;//Le
	laplas = 0;
	
	double **ee = new double*[3];//Ee
	double** ff = new double*[3];
	double** e1 = new double*[3]; 
	double** e2 = new double*[3];
	fp = MyVector3D(rover.x,rover.y,rover.z);//field point初期化
	
	//各配列の初期化
	for (i = 0; i < 3; i++) 
	{
		ee[i] = new double[3];
		ff[i] = new double[3];
		e1[i] = new double[3];
		e2[i] = new double[3];
	}
	
	//面の数だけ計算して足し算
	for( i = 0 ; i < nP ; i++){
		mp = getPosition(i, data, platedata);//ポリゴンの重心位置の取得
		rf = MyVector3D(mp.x - fp.x,mp.y - fp.y,mp.z - fp.z);//ローバの位置から重心までのベクトル
		nf = getNormal(i, data, platedata);//ポリゴンの法線ベクトルを取得
		
		//ローバ位置（field point）から各頂点へのベクトル
		ri.setParameter(data[platedata[i][0]-1][0]-fp.x,data[platedata[i][0]-1][1]-fp.y,data[platedata[i][0]-1][2]-fp.z);
		rj.setParameter(data[platedata[i][1]-1][0]-fp.x,data[platedata[i][1]-1][1]-fp.y,data[platedata[i][1]-1][2]-fp.z);
		rk.setParameter(data[platedata[i][2]-1][0]-fp.x,data[platedata[i][2]-1][1]-fp.y,data[platedata[i][2]-1][2]-fp.z);
		//MyVector3D cross;
		cross.cross(rj, rk);//rjとrkの外積を求める。
		
		dyad(ff,nf, nf);//ダイアドFfを求める。
		
		pxff.setParameter(ff[0][0],ff[1][0],ff[2][0]);//ダイアドの１行目
		pyff.setParameter(ff[0][1],ff[1][1],ff[2][1]);//２行目
		pzff.setParameter(ff[0][2],ff[1][2],ff[2][2]);//３行目
		
		ffpx.setParameter(ff[0][0],ff[0][1],ff[0][2]);
		ffpy.setParameter(ff[1][0],ff[1][1],ff[1][2]);
		ffpz.setParameter(ff[2][0],ff[2][1],ff[2][2]);
		
		rfff.setParameter(rf.dot(pxff),rf.dot(pyff),rf.dot(pzff));//rfとFfの内積を求める
		//rfff.setParameter(rf.dot(ffpx),rf.dot(ffpy),rf.dot(ffpz));//rfとFfの内積を求める
		//wfを計算
		wf = 2*atan((ri.dot(cross))/
					(ri.length()*rj.length()*rk.length() 
					 + ri.length()*(rj.dot(rk)) 
					 + rj.length()*(rk.dot(ri)) 
					 + rk.length()*(ri.dot(rj))));
		
		//ffRf.setParameter(pxff.dot(rf)*wf,pyff.dot(rf)*wf,pzff.dot(rf)*wf);//Ffとrfの内積
		ffRf.setParameter(ffpx.dot(rf)*wf,ffpy.dot(rf)*wf,ffpz.dot(rf)*wf);//Ffとrfの内積

		//ラプラシアンの計算
		laplas += -wf;
		//結果をfaceに足し算
		face+= rfff.dot(rf)*wf;
		
		//傾斜、ナブラUの計算
		nface.x += ffRf.x;
		nface.y += ffRf.y;
		nface.z += ffRf.z;
		
		
		//辺ごとの計算
		//面の中の辺を計算する
		for (int j = 0 ; j < 3; j++) {
			//面の頂点を取得
			indexOfei = platedata[i][(j+1)%3];
			indexOfej = platedata[i][j];
			
			//原点から辺をなす各点へのベクトル
			ei.setParameter(data[indexOfei-1][0],data[indexOfei-1][1],data[indexOfei-1][2]);
			ej.setParameter(data[indexOfej-1][0],data[indexOfej-1][1],data[indexOfej-1][2]);
			
			//辺のベクトルを求める。
			eij.setParameter(ej.x - ei.x, ej.y - ei.y, ej.z - ei.z);
			eji.setParameter(ei.x - ej.x, ei.y - ej.y, ei.z - ej.z);
			
			//field pointから辺へのベクトル
			re.setParameter(ej.x - fp.x, ej.y - fp.y, ej.z - fp.z);
			
			//Leの計算
			vi.setParameter(ei.x - fp.x, ei.y - fp.y, ei.z - fp.z);//field pointから頂点へのベクトル
			vj.setParameter(ej.x - fp.x, ej.y - fp.y, ej.z - fp.z);//同上
			
			le = log((vi.length()+vj.length()+eij.length())/(vi.length()+vj.length()-eij.length()));
			
			//辺を共有する面を検索
			for( int k = 0 ; k < 3 ; k++){
				for( int l = 0 ; l < 3 ; l++){
					p = platedata[commonF[i][k]-1][(l+1)%3];
					q = platedata[commonF[i][k]-1][l];
					if(indexOfei == p && indexOfej == q){
						nfb = getNormal(commonF[i][k]-1, data, platedata);
						flag = 1;
						break;
					}
					else if(indexOfei == q && indexOfej == p){
						nfb = getNormal(commonF[i][k]-1, data, platedata);
						flag = 1;
						break;
					}
				}
				
				if (flag == 1) {
					flag = 0;
					break;
				}
			}
			
			//平面のベクトルを求める
			n12.cross(nf, eij);
			n21.cross(nfb, eji);
			//			if( i == 0 )printf("n12:%d %e %e %e %lf\n",j,n12.x,n12.y,n12.z,n12.length());
			
			n12.normalize();//正規化
			n21.normalize();//正規化
			//			if( i == 0 )printf("nn12:%d %e %e %e %lf\n",j,n12.x,n12.y,n12.z,n12.length());
			
			//Eeの計算
			dyad(e1,nf, n12);//naとn12のダイアド
			dyad(e2,nfb, n21);//nbとn21のダイアド
			
			//e1+e2を行う
			for (int k = 0 ; k < 3; k++) {
				for (int l = 0 ; l < 3; l++) {
					ee[k][l] = e1[k][l] + e2[k][l];
				}
			}
			
			pxee.setParameter(ee[0][0],ee[1][0],ee[2][0]);//Eeの１行目
			pyee.setParameter(ee[0][1],ee[1][1],ee[2][1]);//２行目
			pzee.setParameter(ee[0][2],ee[1][2],ee[2][2]);//３行目
			
			eepx.setParameter(ee[0][0],ee[0][1],ee[0][2]);//Eeの１行目
			eepy.setParameter(ee[1][0],ee[1][1],ee[1][2]);//２行目
			eepz.setParameter(ee[2][0],ee[2][1],ee[2][2]);//３行目
			
			reee.setParameter(re.dot(pxee),re.dot(pyee),re.dot(pzee));//reとEeの内積
			eeRe.setParameter(eepx.dot(re)*le,eepy.dot(re)*le,eepz.dot(re)*le);
			
			//結果を足していく
			edges += reee.dot(re)*le;
			//傾斜のエッジ部分計算
			nedges.x += eeRe.x;
			nedges.y += eeRe.y;
			nedges.z += eeRe.z;
		}		//面の中の辺を計算するforループ終点
	}//面の計算終点
	
	edges/=2.0;//重複分を削る
	nedges.x/=2.0;
	nedges.y/=2.0;
	nedges.z/=2.0;
	
	u = G*density*(-face+edges)/2.0;
	//printf("gravitaioncalc: %e\n",);
	//printf("face %e , edge %e",face,edges);
	nu.setParameter(G*density*(nface.x-nedges.x),G*density*(nface.y-nedges.y),G*density*(nface.z-nedges.z));
	
	return nu;
}

//指定したポリゴンの重心を取得するベクトル(指定するポリゴンID、形状モデルの頂点データ、形状モデルの頂点組み合わせデータ)
MyVector3D GravitationCalculator::getPosition(int pID,double** data ,int** verdata){
	MyVector3D p0(data[verdata[pID][0]-1][0],data[verdata[pID][0]-1][1],data[verdata[pID][0]-1][2]);
	MyVector3D p1(data[verdata[pID][1]-1][0],data[verdata[pID][1]-1][1],data[verdata[pID][1]-1][2]);
	MyVector3D p2(data[verdata[pID][2]-1][0],data[verdata[pID][2]-1][1],data[verdata[pID][2]-1][2]);
	
	MyVector3D re((p0.x+p1.x+p2.x)/3.0,(p0.y+p1.y+p2.y)/3.0,(p0.z+p1.z+p2.z)/3.0);
	
	return re;
	
}

//指定したポリゴンの法線ベクトルを取得する関数(指定するポリゴンID、形状モデルの頂点データ、形状モデルの頂点組み合わせデータ)
MyVector3D GravitationCalculator::getNormal(int pID,double** data,int** verdata){
	MyVector3D p0(data[verdata[pID][0]-1][0],data[verdata[pID][0]-1][1],data[verdata[pID][0]-1][2]);
	MyVector3D p1(data[verdata[pID][1]-1][0],data[verdata[pID][1]-1][1],data[verdata[pID][1]-1][2]);
	MyVector3D p2(data[verdata[pID][2]-1][0],data[verdata[pID][2]-1][1],data[verdata[pID][2]-1][2]);
	
	MyVector3D v1(p1.x-p0.x,p1.y-p0.y,p1.z-p0.z);
	MyVector3D v2(p2.x-p0.x,p2.y-p0.y,p2.z-p0.z);
	MyVector3D normal;
	normal.cross(v1, v2);
	normal.normalize();
	
	
	return normal;
	
}

//ダイアド積を行う関数　引数リスト(ダイアド積の結果を格納する配列、ベクトル１、ベクトル２)
void GravitationCalculator::dyad(double** result,MyVector3D a,MyVector3D b){
	
	/*
	 int i;
	 double **result = new double*[3];
	 for (i = 0; i < 3; i++) result[i] = new double[3];
	 */
	result[0][0] = a.x*b.x;
	result[0][1] = a.x*b.y;
	result[0][2] = a.x*b.z;
	result[1][0] = a.y*b.x;
	result[1][1] = a.y*b.y;
	result[1][2] = a.y*b.z;
	result[2][0] = a.z*b.x;
	result[2][1] = a.z*b.y;
	result[2][2] = a.z*b.z;
	
}

//ラプラシアンを取得する関数
double GravitationCalculator::getlaplas(void){
	return this->laplas;
}
	
