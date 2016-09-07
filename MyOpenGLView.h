//
//  MyOpenGLView.h
//
//  Created by Toshihiro Harada on 12/02/19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <OPENGL/glu.h>

/*
#include "SpiceUsr.h"
#include "SpiceDLA.h"
#include "SpiceDSK.h"
 */
#import "GetData.h"
#import "SetupWindowController.h"
#import "CalcTrajectory.h"
#import "CalLib.h"
#import "Rover.h"
#import "MyVector3D.h"
#import "ShadowRender.h"
#include <vector>
#import <string>
#import <time.h>

using namespace std;
@interface MyOpenGLView : NSOpenGLView {

	IBOutlet NSButton *changeViewButton;
	IBOutlet NSButton *startAnimeButton;
	IBOutlet NSButton *stopAnimeButton;
	IBOutlet NSComboBox *selectAnimeSpeed;
	IBOutlet NSComboBox *combRoverScale;
	IBOutlet NSWindow *setupWindow;
	IBOutlet NSTextField *initialVelocityField;//0.1
	IBOutlet NSTextField *angleOfdirectionField;//fai
	//IBOutlet NSTextField *angleOfejectionField;//theta
	//IBOutlet NSTextField *angularRateField;
    IBOutlet NSTextField *InitialVerocityX;
    IBOutlet NSTextField *InitialVerocityY;
    IBOutlet NSTextField *InitialVerocityZ;
    IBOutlet NSTextField *InitialPositionX;
    IBOutlet NSTextField *InitialPositionY;
    IBOutlet NSTextField *InitialPositionZ;
	IBOutlet NSTextField *sizeOfroverField;
	IBOutlet NSTextField *massOfroverField;
	IBOutlet NSTextField *densityField;
	IBOutlet NSTextField *rotaionPiriodField;
	IBOutlet NSTextField *reflectionCoefficientField;
	IBOutlet NSTextField *initialPositionField;
	IBOutlet NSTextField *stepSizeField;
	IBOutlet NSTextField *simulationTimeField;
	IBOutlet NSButton *simulateButton;
	IBOutlet NSSlider *timeSlider;
	IBOutlet NSTextField *miniTime;
	IBOutlet NSTextField *maxTime;
	IBOutlet NSTextField *currentTime;
	
	IBOutlet NSButton *cb_inputSpiceKernel;
	IBOutlet NSButton *bt_spiceKernel;
	IBOutlet NSTextField *tf_spiceKernelList;
	IBOutlet NSTextView *tv_spiceKernelList;
	
	IBOutlet NSTextField *tf_smYear;
	IBOutlet NSTextField *tf_smMonth;
	IBOutlet NSTextField *tf_smDate;
	IBOutlet NSTextField *tf_smHour;
	IBOutlet NSTextField *tf_smMinute;
	IBOutlet NSTextField *tf_smSecond;
    
    IBOutlet NSLevelIndicator *ProgressBar;

	NSTimer *timer;
	NSString *currentPath;
	NSString *dskFile;
	NSString *trajFile;
	NSMutableArray *kernelFileList;
	Rover minerva;
	ShadowRender shadowRend;
	MyVector3D rotationAxis;//自転軸
	int** pData; // plate index Data
	int nv,np;//number of vertices , number of plate
	double** vData; // vertecis data
	int** commonF;
	double** plateCdata;
	
	vector<int>* ppp;
	vector<int>* ppm;
	vector<int>* pmp;
	vector<int>* mpp;
	vector<int>* pmm;
	vector<int>* mpm;
	vector<int>* mmp;
	vector<int>* mmm;	
	
	
	double s_rotx,s_roty;
    double Initvx;
    double Initvy;
    double Initvz;
    double Initpx;
    double Initpy;
    double Initpz;
    double Progress;
    
	double v0;// m/s
	double fai;// deg
	double theta;// deg
	double angularRate;// deg/s
	double rSize;// cm
	double rMass;// kg
	double density;
	double w;// hour
	double rc;// 
	double h;// sec
	double limit;// sec
	int iP; // Polygon ID
	int shadowFlag;
	}



@property(readwrite)int** pData;
@property(readwrite)int** commonF;
@property(readwrite)double** vData;
@property(readwrite)vector<int> *ppp,*ppm,*pmp,*mpp,*pmm,*mpm,*mmp,*mmm;
@property(readwrite)int nv,np,iP;
@property(readwrite)double Initvx,Initvy,Initvz,Initpx,Initpy,Initpz,Progress;
@property(readwrite)double v0,fai,theta,density,w,rc,limit;
@property(nonatomic,strong) NSTextField *currentTime;

-(void)awakeFromNib;
-(id)initWithFrame:(NSRect)frameRect;
-(void)reshape;
-(void)loop;
-(void)drawShapeModel;
-(void)drawBoundingShapeModel;
-(void)drawBoundingArea;
-(void)drawRover:(string)fn;
-(void)dealloc;
-(void)startTimer;
-(void)updateTimer:(NSTimer*)aTimer;
-(IBAction)startAnime:(id)sender;
-(IBAction)onSelectOpen:(id)sender;
-(IBAction)onLoadTrajectory:(id)sender;
-(IBAction)onLoadBoundPoint:(id)sender;
-(IBAction)checkFromFile:(id)sender;
-(IBAction)startSimulation:(id)sender;
-(IBAction)stopAnime:(id)sender;
-(IBAction)changeView:(id)sender;
-(IBAction)sliderChanged:(id)sender;
-(void)kernelCheckBoxCont:(id)sender;
-(IBAction)inputKernelList:(id)sender;
-(void)drawTrajectory:(string)fn;
-(void)plotBoundPoint:(string)fn;
-(void)qmul:(double[])r double:(double[])p double:(double[])q;
-(void)qrot:(double[])r double:(double[])q;

@end
