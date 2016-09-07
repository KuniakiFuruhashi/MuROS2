//
//  MyOpenGLView.m
//
//  Created by Toshihiro Harada on 12/02/19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "MyOpenGLView.h"
#define SCALE (2.0 * 3.141592)
///#import <GLKit/GLKit.h>

@implementation MyOpenGLView
@synthesize pData,vData,commonF,nv,np,Initpx,Initpy,Initpz,Initvx,Initvy,Initvz,Progress,v0,fai,theta,w,density,iP,rc,limit,ppp,ppm,pmp,mpp,pmm,mpm,mmp,mmm;
@synthesize currentTime;


//int** plateData;
int flag = 0;
int inputDSKFile = 0;
int inputTrajectoryFile = 0;
int inputBoundPointFile = 0;
int changeviewflag = 0;
double rotx = 0.0, roty = 0.0;
double cameraX = 0.0 , cameraY = 0.0, cameraZ = 30.0;
double cameraAngle=0;
double CAMERASPEED=2.0;
NSPoint startpoint,endpoint,dragpoint;
int cx,cy;
double sx,sy;
double cq[4] = {1.0 , 0.0, 0.0, 0.0};
double tq[4];
double rt[16];


FILE* anifp;
double timecount = 0;
int animflag = 0;

SunPosition sunP;
string fname = "/Desktop/trajectory_data.txt";
string roverShape_fname = "/Desktop/roverShape_data.txt";

string orbitFile = "";
string roverShapeFile;
float LPOSITION[] = {-30,0,-15,1};

float LSPECULAR[] = {0.7,0.7,0.7,1.0};

float LDIFFUSE[] = {0.5,0.5,0.5,1.0};

float LAMBIENT[] = {0.2,0.2,0.2,1.0};

// Material
float MSPECULAR[] = {0.5,0.5,0.5,1.0};
float MDIFFUSE[] = {0.5,0.5,0.5,1.0};
float MAMBIENT[] = {0.2,0.2,0.2,1.0};

float MSHININESS = 5.0;

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)awakeFromNib{
    timer = [
             NSTimer scheduledTimerWithTimeInterval:0.03
             target:self
             selector:@selector(loop)
             userInfo:nil
             repeats:YES
             ];
}

-(id)initWithFrame:(NSRect)frameRect{
    //OPEN GL draw context
    
    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAColorSize,static_cast<NSOpenGLPixelFormatAttribute>(32.0),
        NSOpenGLPFADepthSize,static_cast<NSOpenGLPixelFormatAttribute>(32.0),
        0
    };
    
    NSOpenGLPixelFormat* pixFmt = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    self = [super initWithFrame:frameRect pixelFormat:pixFmt];
    [[self openGLContext] makeCurrentContext];
    //[self startTimer];
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glEnable(GL_COLOR_MATERIAL);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    rotationAxis.setParameter(0, 0, 1);
    NSRect bounds = [self bounds];
    currentPath = NSHomeDirectory();
    orbitFile = [currentPath UTF8String] + fname;
    roverShapeFile = [currentPath UTF8String] + roverShape_fname;
    minerva = Rover(1.0,1.0,1.0,1.0,1.0);
    sx = 1.0/(double)bounds.size.width;
    sy = 1.0/(double)bounds.size.height;
    [self qrot:rt double:cq];
    shadowFlag = 0;
    //[currentTime setFloatValue:(float)[timeSlider floatValue]];
    
    //currentTime.text = [timeSlider value];
    printf("init\n");
    
    
    return self;
}

-(void) loop{
    glClearColor(0.0f,0.0f,0.0f,0.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glLoadIdentity();
    
    gluLookAt(cameraX, cameraY, cameraZ, 0, 0, 0, 0, 1, 0);
    //GLKMatrix3Make(cameraX, cameraY, cameraZ,0 ,0, 0, 0, 1, 0);
    //GLKMatrix4MakeLookAt(cameraX, cameraY, cameraZ , 0, 0, 0, 0, 1, 0);
    
    //draw opengl
    glMultMatrixd(rt);
    glPushMatrix();
    
    glLightfv( GL_LIGHT0, GL_POSITION, LPOSITION);
    
    //glLightfv( GL_LIGHT0, GL_SPECULAR, LSPECULAR);
    //glLightfv( GL_LIGHT0, GL_DIFFUSE, LDIFFUSE);
    //glLightfv( GL_LIGHT0, GL_AMBIENT, LAMBIENT);
    
    //glMaterialfv( GL_FRONT, GL_SPECULAR, MSPECULAR);
    //glMaterialfv( GL_FRONT, GL_DIFFUSE, MDIFFUSE);
    //glMaterialfv( GL_FRONT, GL_AMBIENT, MAMBIENT);
    //glMaterialf( GL_FRONT, GL_SHININESS, MSHININESS );
    
    glPushMatrix();
    
    glDisable(GL_LIGHTING);
    glDisable(GL_LIGHT0);
    if(inputDSKFile==0){
        
        startAnimeButton.enabled=NO;
        stopAnimeButton.enabled=NO;
        selectAnimeSpeed.enabled=NO;
        combRoverScale.enabled=NO;
        changeViewButton.enabled=NO;
        timeSlider.enabled=NO;
    }
    else{
        selectAnimeSpeed.enabled=YES;
        combRoverScale.enabled=YES;
        changeViewButton.enabled=YES;
        timeSlider.enabled=YES;
    }
    
    if(inputTrajectoryFile != 0){
        //[self drawRover:roverShapeFile];
        [self drawRover:orbitFile];
        [self drawTrajectory:orbitFile];
    }
    if(inputBoundPointFile != 0){
        //[self drawRover:roverShapeFile];
//        [self drawRover:orbitFile];
        [self plotBoundPoint:orbitFile];
    }
    
    if ([cb_inputSpiceKernel state] == FALSE) {
        //glEnable(GL_LIGHTING);
        //glEnable(GL_LIGHT0);
    }
    
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    
    if(flag == 1) {
        if (changeviewflag == 0) {
            [self drawShapeModel];
        }
        
        else if (changeviewflag == 1)
        {
            [self drawBoundingShapeModel];
            glDisable(GL_LIGHTING);
            glDisable(GL_LIGHT0);
            [self drawBoundingArea];
            glEnable(GL_LIGHTING);
            glEnable(GL_LIGHT0);
        }
        
    }
    
    glPopMatrix();
    glPopMatrix();
    glFinish();
    
    //if(flag == 1) printf("%d\n",pData[0][1] );
    //printf("loop\n");
    [[self openGLContext]flushBuffer];
}


-(void)drawShapeModel{
    int i;
    
    MyVector3D p0;
    MyVector3D p1;
    MyVector3D p2;
    MyVector3D v1;
    MyVector3D v2;
    MyVector3D norm;
    for(i = 0 ; i < np ; i++){
        p0.setParameter(vData[pData[i][0]-1][0],vData[pData[i][0]-1][1],vData[pData[i][0]-1][2]);
        p1.setParameter(vData[pData[i][1]-1][0],vData[pData[i][1]-1][1],vData[pData[i][1]-1][2]);
        p2.setParameter(vData[pData[i][2]-1][0],vData[pData[i][2]-1][1],vData[pData[i][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        //glBegin(GL_LINE_LOOP);
        if (shadowFlag == 1 && [cb_inputSpiceKernel state] == TRUE) {
            glColor3d(plateCdata[i][0], plateCdata[i][1], plateCdata[i][2]);
        }
        else{
            glColor3d(0.7, 0.7, 0.7);
        }
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
        
    }
}

-(void)drawTrajectory:(string) fn
{
    FILE* fp;
    //printf("drawtrajectory\n");
    int f0,f1;
    double p0x,p0y,p0z,p1x,p1y,p1z;
    if((fp = fopen(fn.c_str(),"r")) == NULL)
    {
        printf("File do not exist 1.\n");
        exit(0);
    }
        //fscanf(fp, "%lf%lf%d",&h,&limit,&kernelFlag);
    fscanf(fp,"%lf%lf%lf",&p0x,&p0y,&p0z);

    //while (fscanf(fp,"%lf%lf%lf%lf%lf%lf%lf%lf%lf",&t,&p1x,&p1y,&p1z,&p1l,&v1x,&v1y,&v1z,&u) != EOF)
    while (fscanf(fp,"%lf%lf%lf",&p1x,&p1y,&p1z) != EOF)
    {
        //printf("number:%lf %lf %lf\n",p1x,p1y,p1z);
        if(f0 != f1){
            f0 = f1;
            p0x = p1x;
            p0y = p1y;
            p0z = p1z;
            continue;
        }
        
        glColor3d(255, 255, 0);
        glLineWidth(0.5);
        glBegin(GL_LINES);
        glVertex3d(p0x, p0y, p0z);
        glVertex3d(p1x, p1y, p1z);
        glEnd();
        
        p0x = p1x;
        p0y = p1y;
        p0z = p1z;
    }
    //limit = t;
    fclose(fp);
  
}
-(void)plotBoundPoint:(string) fn
{
     
     FILE* fp;
     
     int i;
     
     double px,py,pz;
     if((fp = fopen(fn.c_str(),"r")) == NULL)
     {
     printf("File do not exist 1.\n");
     exit(0);
     }
     
     while (fscanf(fp,"%d%lf%lf%lf",&i,&px,&py,&pz) != EOF)
     {
         if(i == 0){
     glColor3d(255, 255, 0);
         }else if(i == 1){
     glColor3d(255,0,255);
         }else{
     glColor3d(0, 255, 255);
         }
     glPointSize(3);
     glBegin(GL_POINTS);
     glVertex3d(px, py, pz);
     glEnd();
     
     }
     
     fclose(fp);
    
}

-(void)drawBoundingShapeModel
{
    MyVector3D p0;
    MyVector3D p1;
    MyVector3D p2;
    MyVector3D v1;
    MyVector3D v2;
    MyVector3D norm;
    
    for (int i = 0 ; i < (*ppp).size(); i++) { /* 第一象限 */
        glColor3d(1.0, 0, 0);
        p0.setParameter(vData[pData[(*ppp)[i]-1][0]-1][0],vData[pData[(*ppp)[i]-1][0]-1][1],vData[pData[(*ppp)[i]-1][0]-1][2]);
        p1.setParameter(vData[pData[(*ppp)[i]-1][1]-1][0],vData[pData[(*ppp)[i]-1][1]-1][1],vData[pData[(*ppp)[i]-1][1]-1][2]);
        p2.setParameter(vData[pData[(*ppp)[i]-1][2]-1][0],vData[pData[(*ppp)[i]-1][2]-1][1],vData[pData[(*ppp)[i]-1][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
    }
    
    for (int i = 0 ; i < (*ppm).size(); i++) { /* 第二象限 */
        glColor3d(0, 1.0, 0);
        
        p0.setParameter(vData[pData[(*ppm)[i]-1][0]-1][0],vData[pData[(*ppm)[i]-1][0]-1][1],vData[pData[(*ppm)[i]-1][0]-1][2]);
        p1.setParameter(vData[pData[(*ppm)[i]-1][1]-1][0],vData[pData[(*ppm)[i]-1][1]-1][1],vData[pData[(*ppm)[i]-1][1]-1][2]);
        p2.setParameter(vData[pData[(*ppm)[i]-1][2]-1][0],vData[pData[(*ppm)[i]-1][2]-1][1],vData[pData[(*ppm)[i]-1][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
        
    }
    
    for (int i = 0 ; i < (*pmp).size(); i++) {
        glColor3d(0, 0, 1.0);
        
        p0.setParameter(vData[pData[(*pmp)[i]-1][0]-1][0],vData[pData[(*pmp)[i]-1][0]-1][1],vData[pData[(*pmp)[i]-1][0]-1][2]);
        p1.setParameter(vData[pData[(*pmp)[i]-1][1]-1][0],vData[pData[(*pmp)[i]-1][1]-1][1],vData[pData[(*pmp)[i]-1][1]-1][2]);
        p2.setParameter(vData[pData[(*pmp)[i]-1][2]-1][0],vData[pData[(*pmp)[i]-1][2]-1][1],vData[pData[(*pmp)[i]-1][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
    }
    for (int i = 0 ; i < (*mpp).size(); i++) {
        glColor3d(1.0, 1.0, 0);
        
        p0.setParameter(vData[pData[(*mpp)[i]-1][0]-1][0],vData[pData[(*mpp)[i]-1][0]-1][1],vData[pData[(*mpp)[i]-1][0]-1][2]);
        p1.setParameter(vData[pData[(*mpp)[i]-1][1]-1][0],vData[pData[(*mpp)[i]-1][1]-1][1],vData[pData[(*mpp)[i]-1][1]-1][2]);
        p2.setParameter(vData[pData[(*mpp)[i]-1][2]-1][0],vData[pData[(*mpp)[i]-1][2]-1][1],vData[pData[(*mpp)[i]-1][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
    }
    for (int i = 0 ; i < (*pmm).size(); i++) {
        glColor3d(1.0, 0, 1.0);
        
        p0.setParameter(vData[pData[(*pmm)[i]-1][0]-1][0],vData[pData[(*pmm)[i]-1][0]-1][1],vData[pData[(*pmm)[i]-1][0]-1][2]);
        p1.setParameter(vData[pData[(*pmm)[i]-1][1]-1][0],vData[pData[(*pmm)[i]-1][1]-1][1],vData[pData[(*pmm)[i]-1][1]-1][2]);
        p2.setParameter(vData[pData[(*pmm)[i]-1][2]-1][0],vData[pData[(*pmm)[i]-1][2]-1][1],vData[pData[(*pmm)[i]-1][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
    }
    for (int i = 0 ; i < (*mpm).size(); i++) {
        glColor3d(0, 1.0, 1.0);
        
        p0.setParameter(vData[pData[(*mpm)[i]-1][0]-1][0],vData[pData[(*mpm)[i]-1][0]-1][1],vData[pData[(*mpm)[i]-1][0]-1][2]);
        p1.setParameter(vData[pData[(*mpm)[i]-1][1]-1][0],vData[pData[(*mpm)[i]-1][1]-1][1],vData[pData[(*mpm)[i]-1][1]-1][2]);
        p2.setParameter(vData[pData[(*mpm)[i]-1][2]-1][0],vData[pData[(*mpm)[i]-1][2]-1][1],vData[pData[(*mpm)[i]-1][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
    }
    for (int i = 0 ; i < (*mmp).size(); i++) {
        glColor3d(0.5, 0.5, 0);
        
        p0.setParameter(vData[pData[(*mmp)[i]-1][0]-1][0],vData[pData[(*mmp)[i]-1][0]-1][1],vData[pData[(*mmp)[i]-1][0]-1][2]);
        p1.setParameter(vData[pData[(*mmp)[i]-1][1]-1][0],vData[pData[(*mmp)[i]-1][1]-1][1],vData[pData[(*mmp)[i]-1][1]-1][2]);
        p2.setParameter(vData[pData[(*mmp)[i]-1][2]-1][0],vData[pData[(*mmp)[i]-1][2]-1][1],vData[pData[(*mmp)[i]-1][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
    }
    for (int i = 0 ; i < (*mmm).size(); i++) {
        glColor3d(0, 0.5, 0.5);
        
        p0.setParameter(vData[pData[(*mmm)[i]-1][0]-1][0],vData[pData[(*mmm)[i]-1][0]-1][1],vData[pData[(*mmm)[i]-1][0]-1][2]);
        p1.setParameter(vData[pData[(*mmm)[i]-1][1]-1][0],vData[pData[(*mmm)[i]-1][1]-1][1],vData[pData[(*mmm)[i]-1][1]-1][2]);
        p2.setParameter(vData[pData[(*mmm)[i]-1][2]-1][0],vData[pData[(*mmm)[i]-1][2]-1][1],vData[pData[(*mmm)[i]-1][2]-1][2]);
        
        v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
        v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
        
        norm.cross(v1, v2);
        norm.normalize();
        
        glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
        
        glBegin(GL_TRIANGLES);
        glVertex3d(p0.x, p0.y, p0.z);
        glVertex3d(p1.x, p1.y, p1.z);
        glVertex3d(p2.x, p2.y, p2.z);
        glEnd();
    }
    
}

-(void)drawBoundingArea /* ３軸 */
{
    glLineWidth(2);
    
    //x-axis
    glColor3d(0, 1.0, 0);//green
    glBegin(GL_LINES);
    glVertex3d(0.5, 0, 0);
    glVertex3d(0, 0, 0);
    glVertex3d(0.5,0.05,0.05);
    glVertex3d(0.5,-0.05,-0.05);
    glVertex3d(0.5, 0.05, -0.05);
    glVertex3d(0.5, -0.05, 0.05);
    glEnd();
    
    //y-axis
    glColor3d(1.0, 0, 0);//red
    glBegin(GL_LINES);
    glVertex3d(0, 0.5, 0);
    glVertex3d(0, 0, 0);
    glVertex3d(-0.05,0.5,-0.05);
    glVertex3d(0, 0.5, 0);
    glVertex3d(0.05,0.5,-0.05);
    glVertex3d(0, 0.5, 0);
    glVertex3d(0,0.5,0.05);
    glVertex3d(0, 0.5, 0);
    
    glEnd();
    
    //z-axis
    glColor3d(0, 0, 1.0);//blue
    glBegin(GL_LINES);
    glVertex3d(    0,    0,    0);
    glVertex3d(    0,    0,  0.5);
    glVertex3d(-0.05,  0.05, 0.5);
    glVertex3d( 0.05,  0.05, 0.5);
    glVertex3d( 0.05,  0.05, 0.5);
    glVertex3d(-0.05, -0.05, 0.5);
    glVertex3d(-0.05, -0.05, 0.5);
    glVertex3d( 0.05, -0.05, 0.5);
    glEnd();
}

-(void)drawRover:(string)fn
{
    double cx,cy,cz;
    MyVector3D p0;
    MyVector3D p1;
    MyVector3D p2;
    MyVector3D p3;
    MyVector3D v1;
    MyVector3D v2;
    MyVector3D norm;
    int collisionPid;
    int kernelFlag;
    double t,p0l,v0x,v0y,v0z,u;
    double wx,wy,wz;
    double sunx,suny,sunz;
    double fh,flimit;
    double r_shape[8][3];
    double scale = [combRoverScale doubleValue];
    FILE *fp;
    if((fp = fopen(fn.c_str(),"r")) == NULL)
    {
        printf("File do not exist 2.\n");
        exit(0);
    }
    
    fscanf(fp, "%lf%lf%d",&fh,&flimit,&kernelFlag);
    
    
    while(fscanf(fp,"%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%lf%d%lf%lf%lf",&t,&cx,&cy,&cz,&p0l,&v0x,&v0y,&v0z,&wx,&wy,&wz,&u,
                 &r_shape[0][0],&r_shape[0][1],&r_shape[0][2],
                 &r_shape[1][0],&r_shape[1][1],&r_shape[1][2],
                 &r_shape[2][0],&r_shape[2][1],&r_shape[2][2],
                 &r_shape[3][0],&r_shape[3][1],&r_shape[3][2],
                 &r_shape[4][0],&r_shape[4][1],&r_shape[4][2],
                 &r_shape[5][0],&r_shape[5][1],&r_shape[5][2],
                 &r_shape[6][0],&r_shape[6][1],&r_shape[6][2],
                 &r_shape[7][0],&r_shape[7][1],&r_shape[7][2],&collisionPid,&sunx,&suny,&sunz) != EOF){
        
        if(t == timecount){
            
            if (kernelFlag == 1) {
                LPOSITION[0] = sunx;
                LPOSITION[1] = suny;
                LPOSITION[2] = sunz;
            }
            r_shape[0][0] = ((r_shape[0][0] - cx)*scale) + cx; r_shape[0][1] = ((r_shape[0][1] - cy)*scale) + cy; r_shape[0][2] = ((r_shape[0][2] - cz)*scale) + cz;
            r_shape[1][0] = ((r_shape[1][0] - cx)*scale) + cx; r_shape[1][1] = ((r_shape[1][1] - cy)*scale) + cy; r_shape[1][2] = ((r_shape[1][2] - cz)*scale) + cz;
            r_shape[2][0] = ((r_shape[2][0] - cx)*scale) + cx; r_shape[2][1] = ((r_shape[2][1] - cy)*scale) + cy; r_shape[2][2] = ((r_shape[2][2] - cz)*scale) + cz;
            r_shape[3][0] = ((r_shape[3][0] - cx)*scale) + cx; r_shape[3][1] = ((r_shape[3][1] - cy)*scale) + cy; r_shape[3][2] = ((r_shape[3][2] - cz)*scale) + cz;
            r_shape[4][0] = ((r_shape[4][0] - cx)*scale) + cx; r_shape[4][1] = ((r_shape[4][1] - cy)*scale) + cy; r_shape[4][2] = ((r_shape[4][2] - cz)*scale) + cz;
            r_shape[5][0] = ((r_shape[5][0] - cx)*scale) + cx; r_shape[5][1] = ((r_shape[5][1] - cy)*scale) + cy; r_shape[5][2] = ((r_shape[5][2] - cz)*scale) + cz;
            r_shape[6][0] = ((r_shape[6][0] - cx)*scale) + cx; r_shape[6][1] = ((r_shape[6][1] - cy)*scale) + cy; r_shape[6][2] = ((r_shape[6][2] - cz)*scale) + cz;
            r_shape[7][0] = ((r_shape[7][0] - cx)*scale) + cx; r_shape[7][1] = ((r_shape[7][1] - cy)*scale) + cy; r_shape[7][2] = ((r_shape[7][2] - cz)*scale) + cz;
            for (int i = 0 ; i < 6 ;  i++ ) {
                glColor3d(0.5, 0.5, 0.5);
                if (i == 0) {
                    //z-axis
                    glColor3d(0, 0, 1);
                }
                if (i == 3) {
                    //x-axis
                    glColor3d(0,1, 0);
                }
                if (i == 4) {
                    //y-axis
                    glColor3d(1, 0, 0);
                }
                if (i == 1) {
                    //z-axis?
                    glColor3d(1, 0, 1);
                }
                if (i == 2) {
                    //x-axi?
                    glColor3d(0,1, 1);
                }
                if (i == 5) {
                    //y-axis
                    glColor3d(1, 1, 0);
                }
                
                p0.setParameter(r_shape[minerva.b_index[i][0]][0], r_shape[minerva.b_index[i][0]][1], r_shape[minerva.b_index[i][0]][2]);
                p1.setParameter(r_shape[minerva.b_index[i][1]][0], r_shape[minerva.b_index[i][1]][1], r_shape[minerva.b_index[i][1]][2]);
                p2.setParameter(r_shape[minerva.b_index[i][2]][0], r_shape[minerva.b_index[i][2]][1], r_shape[minerva.b_index[i][2]][2]);
                p3.setParameter(r_shape[minerva.b_index[i][3]][0], r_shape[minerva.b_index[i][3]][1], r_shape[minerva.b_index[i][3]][2]);
                v1.setParameter(p1.x - p0.x,p1.y - p0.y,p1.z - p0.z);
                v2.setParameter(p2.x - p1.x,p2.y - p1.y,p2.z - p1.z);
                
                norm.cross(v1, v2);
                norm.normalize();
                //if(i == 0)printf("norm:%lf %e %e %e\n",t,norm.x,norm.y,norm.z);
                glNormal3d((GLdouble)norm.x, (GLdouble)norm.y, (GLdouble)norm.z);
                glBegin(GL_QUADS);
                //glVertex3d(p0.x * scale, p0.y * scale, p0.z * scale);
                //glVertex3d(p1.x * scale, p1.y * scale, p1.z * scale);
                //glVertex3d(p2.x * scale, p2.y * scale, p2.z * scale);
                //glVertex3d(p3.x * scale, p3.y * scale, p3.z * scale);
                glVertex3d(p0.x, p0.y, p0.z);
                glVertex3d(p1.x, p1.y, p1.z);
                glVertex3d(p2.x, p2.y, p2.z);
                glVertex3d(p3.x, p3.y, p3.z);
                glEnd();
            }
        }
        //counter += h;
        
    }
    fclose(fp);
}

-(void)reshape{
    NSRect bounds = [self bounds];
    glViewport(
               (int)bounds.origin.x,(int)bounds.origin.y,
               (int)bounds.size.width,(int)bounds.size.height
               );
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    gluPerspective(2, (float)bounds.size.width/(float)bounds.size.height, 1.0, 500.0);
    //GLKMatrix4MakePerspective(2, (float)bounds.size.width/(float)bounds.size.height, 1.0, 500.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

//Animationスタートメソッド
-(void)startTimer{
    
    if (timecount == 0) {
        
        /*
         CalLib clb;
         MyVector3D rp;
         MyVector3D pn;
         MyVector3D equa;
         MyVector3D direct;
         rp = clb.getGravityCenter(iP-1, vData, pData);
         pn = clb.getNormalVector(iP-1, vData, pData);
         minerva = Rover(rSize, rp.x, rp.y, rp.z);
         equa.cross(pn, rotationAxis);
         direct.cross(equa, pn);
         printf("setRover:%lf\n",minerva.rsize);
         minerva.setAttiRover(pn, rp, direct, theta);
         */
        timer = [ NSTimer scheduledTimerWithTimeInterval:h/[selectAnimeSpeed doubleValue]
                                                 target : self
                                               selector : @selector( updateTimer : )
                                               userInfo : nil
                                                repeats : YES ];
    }
    else {
        timecount = 0;
        timer = [ NSTimer scheduledTimerWithTimeInterval:h/[selectAnimeSpeed doubleValue]
                                                 target : self
                                               selector : @selector( updateTimer : )
                                               userInfo : nil
                                                repeats : YES ];
    }
    printf("current anime speed:%lf\n",h/[selectAnimeSpeed doubleValue]);
}

//アニメーション時に行う処理
-(void)updateTimer:(NSTimer*) aTimer{
    [timeSlider setDoubleValue:timecount];
    [currentTime setDoubleValue:[timeSlider doubleValue]];
    
    timecount += h;
    
    if (timecount > limit)
    {
        timecount = limit;
        [timeSlider setDoubleValue:timecount];
        [timer invalidate];
        startAnimeButton.enabled=YES;
        stopAnimeButton.enabled=NO;
    }
    
    [self setNeedsDisplay:YES];
    [self display];
    
}

-(void)dealloc{
    [timer invalidate];
}



//DSKファイル入力用メソッド
-(IBAction)onSelectOpen:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSArray *allowedFileTypes = [NSArray arrayWithObjects:/* @"txt", */@"bds",nil];
    
    [openPanel setAllowedFileTypes:allowedFileTypes];
    NSInteger pressedButton = [openPanel runModal];
    
    if(pressedButton == NSOKButton){
        
        NSURL *filePath = [openPanel URL];
        dskFile  = [filePath relativePath];
        printf("file opened %s",[dskFile UTF8String]) ;
        
        GetData getdata([dskFile UTF8String],[currentPath UTF8String]);
        np = getdata.getNumberOfPlate();
        nv = getdata.getNumberOfVertices();
        
        pData = getdata.getPlateData();
        vData = getdata.getVerticesData();
        commonF = getdata.getCommonF();
        ppp = getdata.getppp();
        ppm = getdata.getppm();
        pmp = getdata.getpmp();
        mpp = getdata.getmpp();
        pmm = getdata.getpmm();
        mpm = getdata.getmpm();
        mmp = getdata.getmmp();
        mmm = getdata.getmmm();
        
        flag = 1;
        inputDSKFile=1;
        printf("input DSKFile=%d",inputDSKFile);
        
    }else if (pressedButton == NSCancelButton) {
        NSLog(@"Cancel button was pressed.");
    }
    else {
        
    }
    
    
}
//トラジェクトリファイルのロードに関する処理
-(IBAction)onLoadTrajectory:(id)sender
{
    NSOpenPanel *selectTrajectoryPanel = [NSOpenPanel openPanel];
    NSArray *allowdFileTypes = [NSArray arrayWithObjects:@"txt",@"dat",nil];
    
    [selectTrajectoryPanel setAllowedFileTypes:allowdFileTypes];
    NSInteger pressedButton = [selectTrajectoryPanel runModal];
    
    if(pressedButton == NSOKButton){
        NSURL *filePath = [selectTrajectoryPanel URL];
        orbitFile = [[filePath relativePath] UTF8String];
        inputTrajectoryFile = 1;
        printf("trajectory file opened %s",orbitFile.c_str()) ;
        
        FILE *fp;
        if((fp = fopen(orbitFile.c_str(),"r")) == NULL)
        {
            printf("File do not exist 3.\n");
            exit(0);
        }
        fscanf(fp, "%lf%lf",&h,&limit);
        
        [timeSlider setMaxValue:limit];
        [maxTime setDoubleValue:limit];
        [timeSlider setDoubleValue:0];
        startAnimeButton.enabled=YES;
        
    }else if (pressedButton == NSCancelButton) {
        NSLog(@"Cancel button was pressed.");
    }
    else {
        
    }
    
    
}

//ここに書く
-(IBAction)onLoadBoundPoint:(id)sender
{
    
    NSOpenPanel *selectTrajectoryPanel = [NSOpenPanel openPanel];
    NSArray *allowdFileTypes = [NSArray arrayWithObjects:@"txt",@"dat",nil];
    
    [selectTrajectoryPanel setAllowedFileTypes:allowdFileTypes];
    NSInteger pressedButton = [selectTrajectoryPanel runModal];
    
    if(pressedButton == NSOKButton){
        NSURL *filePath = [selectTrajectoryPanel URL];
        orbitFile = [[filePath relativePath] UTF8String];
        inputBoundPointFile = 1;
        printf("BoundPoint file opened %s",orbitFile.c_str()) ;
        
        FILE *fp;
        if((fp = fopen(orbitFile.c_str(),"r")) == NULL)
        {
            printf("File do not exist 3.\n");
            exit(0);
        }
        fscanf(fp, "%lf%lf",&h,&limit);
        
        [timeSlider setMaxValue:limit];
        [maxTime setDoubleValue:limit];
        [timeSlider setDoubleValue:0];
        startAnimeButton.enabled=YES;
        
    }else if (pressedButton == NSCancelButton) {
        NSLog(@"Cancel button was pressed.");
    }
    else {
        
    }

}


-(IBAction)checkFromFile:(id)sender
{
    
    
    
}

-(IBAction)startAnime:(id)sender
{
    if (inputTrajectoryFile == 1) {
        startAnimeButton.enabled=NO;
        stopAnimeButton.enabled=YES;
        [self startTimer];
        
        
    }
    else {
        printf("not a trajectory file!!\n");
    }
    
    
}

-(IBAction)stopAnime:(id)sender
{
    stopAnimeButton.enabled=NO;
    [timer invalidate];
    startAnimeButton.enabled=YES;
}
-(IBAction)startSimulation:(id)sender
{
    
    CalLib clb;
    CalcTrajectory *calcTraj = [[CalcTrajectory alloc] init];
    MyVector3D rp;
    MyVector3D pn;
    MyVector3D equa;
    MyVector3D direct;
    string sm_year;
    string sm_month;
    string sm_date;
    string sm_hour;
    string sm_minute;
    string sm_second;
    string timeStr;
    clock_t start,end;
    if(nv == 0 || np == 0){
        printf("Please open dsk file!\n");
        
    }
    else {
        Initpx = [InitialPositionX doubleValue]/1000.0;
        Initpy = [InitialPositionY doubleValue]/1000.0;
        Initpz = [InitialPositionZ doubleValue]/1000.0;
        Initvx = [InitialVerocityX doubleValue];
        Initvy = [InitialVerocityY doubleValue];
        Initvz = [InitialVerocityZ doubleValue];
        
        //v0 = [initialVelocityField doubleValue]; //初速度
        //fai = [angleOfejectionField doubleValue]; //放出角度
        fai=0;
        theta = [angleOfdirectionField doubleValue]; //方位角度
        //theta=0;
        density = [densityField doubleValue]*1e+12; //密度
        angularRate = 0; //回転角速度
        rSize = [sizeOfroverField doubleValue]/1E+5; //ローバーサイズ
        rMass = [massOfroverField doubleValue]; //ローバー質量
        w = ((2*M_PI)/([rotaionPiriodField doubleValue]*60*60)); //自転周期
        rc = [reflectionCoefficientField doubleValue]; //表面反発係数
        iP = 0; //ポリゴンID
        h = [stepSizeField doubleValue]; //ステップ幅
        limit = [simulationTimeField doubleValue]; //シミュレーション限界時間
        
        //スライダー初期化
        [ProgressBar setFloatValue:50.0];
        [timeSlider setMaxValue:limit];
        [maxTime setDoubleValue:limit];
        [timeSlider setDoubleValue:0];
        [currentTime setDoubleValue:[timeSlider doubleValue]];
        printf("\n");
        printf("h:%lf limit:%lf",h,limit);
        printf("pid %d %e %e %e\n",iP,vData[pData[iP][0]][0],vData[pData[iP][0]][1],vData[pData[iP][0]][2]);
        if (v0 != 0 || fai != 0 || theta != 0 || density != 0 || w != 0) {
            rp = clb.getGravityCenter(iP, vData, pData);
            pn = clb.getNormalVector(iP, vData, pData);
            minerva = Rover(rSize, rp.x, rp.y, rp.z,rMass);
            equa.cross(pn, rotationAxis);
            direct.cross(equa, pn);
            printf("setRover:%lf\n",minerva.rsize);
            //minerva.setAttiRover(pn, rp, direct, theta);
            [calcTraj setAreaGroup:ppp ppm:ppm pmp:pmp mpp:mpp pmm:pmm mpm:mpm mmp:mmp mmm:mmm];
            start = clock();
            if ([cb_inputSpiceKernel state] == TRUE && [kernelFileList count] != 0) {
                
                //string kernelStr[[kernelFileList count]];
                
                vector<string> kernelStr;
                //for (int i = 0 ;  i < [kernelFileList count]; i++) {
                //kernelStr[i] = [[kernelFileList objectAtIndex:i] UTF8String];
                //}
                sm_year = [[tf_smYear stringValue] UTF8String];
                sm_month = [[tf_smMonth stringValue] UTF8String];
                sm_date = [[tf_smDate stringValue] UTF8String];
                sm_hour = [[tf_smHour stringValue] UTF8String];
                sm_minute = [[tf_smMinute stringValue] UTF8String];
                sm_second = [[tf_smSecond stringValue] UTF8String];
                timeStr = timeStr + sm_year + "-" + sm_month + "-" + sm_date + "T" + sm_hour + ":" + sm_minute + ":" + sm_second;
                sunP = SunPosition(kernelStr, [kernelFileList count], timeStr);
                
                [calcTraj vp:clb.getGravityCenter(iP, vData, pData) normalVec:clb.getNormalVector(iP, vData, pData) verticesData:vData plateData:pData commonFData:commonF numberOfvertices:nv numberOfplate:np InitPX:Initpx InitPY:Initpy InitPZ:Initpz InitVX:Initvx InitVY:Initvy InitVZ:Initvz fai:fai theta:theta rotationAV:w density:density stepsize:h limit:limit e:rc dskfile:[dskFile UTF8String] rsize:rSize rmass:rMass roverAV:angularRate rotationAxis:rotationAxis sunPosition:sunP];
                
                
            }
            else {
                [calcTraj vp:clb.getGravityCenter(iP, vData, pData) normalVec:clb.getNormalVector(iP, vData, pData) verticesData:vData plateData:pData commonFData:commonF numberOfvertices:nv numberOfplate:np InitPX:Initpx InitPY:Initpy InitPZ:Initpz InitVX:Initvx InitVY:Initvy InitVZ:Initvz fai:fai theta:theta rotationAV:w density:density stepsize:h limit:limit e:rc dskfile:[dskFile UTF8String] rsize:rSize rmass:rMass roverAV:angularRate rotationAxis:rotationAxis];
                [ProgressBar setIntValue:100];
            }
            end=clock();
            printf("end simulate, time is %.2fsec. \n",(double)(end-start)/CLOCKS_PER_SEC);
            //orbitFile = [currentPath UTF8String] + fname;
        }
        
    }
    //[calcTraj release];
    inputTrajectoryFile = 1;
    printf("End simulation\n");
    startAnimeButton.enabled=YES;
}

//changeveiwボタンが押された時のイベント
-(IBAction)changeView:(id)sender
{
    if (changeviewflag == 0) {
        changeviewflag = 1;
    }
    else if (changeviewflag == 1){
        changeviewflag = 0;
    }
}

//スライダーを動かした時の処理
-(IBAction)sliderChanged:(id)sender
{
    if ( inputTrajectoryFile == 1) {
        
    }
    printf("%lf\n",[timeSlider doubleValue]);
}

//カーネルを入力するかどうかのチェックボックス
-(void)kernelCheckBoxCont:(id)sender
{
    if ([cb_inputSpiceKernel state] == TRUE) {
        [bt_spiceKernel setHidden:FALSE];
        [tv_spiceKernelList setHidden:FALSE];
    }
    else if([cb_inputSpiceKernel state] == FALSE) {
        [bt_spiceKernel setHidden:TRUE];
        [tv_spiceKernelList setHidden:TRUE];
    }
}

-(IBAction)inputKernelList:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    kernelFileList = [[NSMutableArray alloc] init];
    //NSArray *allowedFileTypes = [NSArray arrayWithObjects:@"txt",@"bds",nil];
    
    //[openPanel setAllowedFileTypes:allowedFileTypes];
    [openPanel setAllowsMultipleSelection:TRUE];
    NSInteger pressedButton = [openPanel runModal];
    //double* sunposition;
    if(pressedButton == NSOKButton){
        
        //NSURL *filePath = [openPanel URLs];
        NSArray *filePath = [openPanel URLs];
        NSString *filestr = [[NSString alloc] init];
        int klcount = [filePath count];
        for (int i = 0 ;  i < klcount; i++) {
            [kernelFileList addObject:[[filePath objectAtIndex:i] relativePath]];
            //[tf_spiceKernelList setStringValue:[kernelFileList objectAtIndex:i]];
            [filestr stringByAppendingString:[kernelFileList objectAtIndex:i]];
            [filestr stringByAppendingString:@"\n"];
            printf("file opened %s",[[kernelFileList objectAtIndex:i] UTF8String] ) ;
            
        }
        [tv_spiceKernelList setString:[kernelFileList objectAtIndex:0]];
        //string kernelStr[[kernelFileList count]];
        //for (int i = 0 ;  i < [kernelFileList count]; i++) {
        //	kernelStr[i] = [[kernelFileList objectAtIndex:i] UTF8String];
        //}
        //shadowRend = ShadowRender(kernelStr, [kernelFileList count]);
        
        //plateCdata = shadowRend.getShadow([dskFile UTF8String],0);
        //sunposition = shadowRend.getSunPosition();
        //LPOSITION[0] = sunposition[0];
        //LPOSITION[1] = sunposition[1];
        //LPOSITION[2] = sunposition[2];
        
        //shadowFlag = 1;
        //dskFile  = [filePath relativePath];
        
    }else if (pressedButton == NSCancelButton) {
        NSLog(@"Cancel button was pressed.");
    }
}


-(void)mouseDown:(NSEvent *)theEvent
{
    
    startpoint = [theEvent locationInWindow];
    
    //ドラッグ開始点を記録
    cx = startpoint.x;
    cy = startpoint.y;
    
}

-(void)mouseUp:(NSEvent *)theEvent
{
    //回転の保存
    cq[0] = tq[0];
    cq[1] = tq[1];
    cq[2] = tq[2];
    cq[3] = tq[3];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    double dx,dy,a;
    dragpoint = [theEvent locationInWindow];
    
    //マウスポインタの位置のドラッグ開始位置からの変異
    dx = (dragpoint.x - cx) * sx;
    dy = (dragpoint.y - cy) * sy;
    
    //dx = (cx - dragpoint.x) * sx;
    //dy = (cy - dragpoint.y) * sy;
    
    //マウスポインタの位置のドラッグ開始位置からの距離
    a = sqrt(dx * dx + dy * dy);
    
    if (a  != 0.0) {
        //マウスのドラッグに伴う回転のクォータニオン dq　を求める。
        double ar = a * SCALE * 0.5;
        double as = sin(ar)/a;
        double dq[4] = { cos(ar), -dy * as, dx * as, 0.0 };
        
        //回転の初期値 cq に　dq を掛けて回転を合成
        //qmul(tq, dq, cq);
        [self qmul:tq double:dq double:cq];
        //クォータニオンから回転の変換行列を求める
        [self qrot:rt double:tq];
        //qrot(rt, tq);
        
    }
    
}

//最新版・小惑星の大小の変化
-(void)scrollWheel:(NSEvent *)theEvent{
    //double cameraVectorX=-CAMERASPEED*sin(cameraAngle/180*M_PI);
    double cameraVectorZ=-CAMERASPEED*cos(cameraAngle/180*M_PI);
    if([theEvent deltaY]>0&& cameraZ>2){
        cameraZ +=cameraVectorZ;
        //printf("cameraZ=%f\n",cameraZ);
    }
    else if([theEvent deltaY]<0 && cameraZ<500){
        cameraZ -=cameraVectorZ;
        //printf("cameraZ=%f\n",cameraZ);
    }
}

-(void)magnifyWithEvent:(NSEvent *)event{
    //   double CameraVectorZ=-CAMERASPEED*cos(cameraAngle/180*M_PI);
    //     if(cameraZ>2 && )
}

//小惑星の大きさを変えてるところ
/*-(void)keyDown:(NSEvent *)theEvent
 {
	printf("keydown\n");
	double cameraVectorX=-CAMERASPEED*sin(cameraAngle/180*M_PI);
	double cameraVectorZ=-CAMERASPEED*cos(cameraAngle/180*M_PI);
	if([[theEvent characters] isEqualTo:@"2"])
	{
 cameraX-=cameraVectorX; cameraZ -=cameraVectorZ;
 
	}
	else if([[theEvent characters] isEqualTo:@"8"])
	{
 cameraX+=cameraVectorX; cameraZ +=cameraVectorZ;
	}
	[super keyDown:theEvent];
 
 }
 */

/*//新設・小惑星を大きくする
 -(IBAction)largerTarget:(id)theEvent{
 double cameraVectorX=-CAMERASPEED*sin(cameraAngle/180*M_PI);
 double cameraVectorZ=-CAMERASPEED*cos(cameraAngle/180*M_PI);
 cameraX+=cameraVectorX; cameraZ +=cameraVectorZ;
 }
 //新設・小惑星を小さくする
 -(IBAction)smallarTarget:(id)theEvent{
 double cameraVectorX=-CAMERASPEED*sin(cameraAngle/180*M_PI);
 double cameraVectorZ=-CAMERASPEED*cos(cameraAngle/180*M_PI);
 cameraX-=cameraVectorX; cameraZ -=cameraVectorZ;
 }
 */



-(void)qmul:(double[])r double:(double[])p double:(double[])q
{
    r[0] = p[0] * q[0] - p[1] * q[1] - p[2] * q[2] - p[3] * q[3];
    r[1] = p[0] * q[1] + p[1] * q[0] + p[2] * q[3] - p[3] * q[2];
    r[2] = p[0] * q[2] - p[1] * q[3] + p[2] * q[0] + p[3] * q[1];
    r[3] = p[0] * q[3] + p[1] * q[2] - p[2] * q[1] + p[3] * q[0];
}

-(void)qrot:(double[])r double:(double[])q
{
    double x2 = q[1] * q[1] * 2.0;
    double y2 = q[2] * q[2] * 2.0;
    double z2 = q[3] * q[3] * 2.0;
    double xy = q[1] * q[2] * 2.0;
    double yz = q[2] * q[3] * 2.0;
    double zx = q[3] * q[1] * 2.0;
    double xw = q[1] * q[0] * 2.0;
    double yw = q[2] * q[0] * 2.0;
    double zw = q[3] * q[0] * 2.0;
    
    r[ 0] = 1.0 - y2 - z2;
    r[ 1] = xy + zw;
    r[ 2] = zx - yw;
    r[ 4] = xy - zw;
    r[ 5] = 1.0 - z2 - x2;
    r[ 6] = yz + xw;
    r[ 8] = zx + yw;
    r[ 9] = yz - xw;
    r[10] = 1.0 - x2 - y2;
    r[ 3] = r[ 7] = r[11] = r[12] = r[13] = r[14] = 0.0;
    r[15] = 1.0;
}



@end
