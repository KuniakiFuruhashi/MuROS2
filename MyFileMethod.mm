//
//  MyFileMethod.m
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/02/19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import "MyFileMethod.h"

//static NSString *filePath = @"/Users/m5151134/shapemodel/itokawa_f0003072.txt";

@implementation MyFileMethod

-(IBAction)readFromFile:(id)sender
{
	//NSString* str;
	//NSArray* arr;
	//NSArray* arr2;
    //int np;
    int nv;
	int** plateData;
	double** verticesData;
	
	myopengl = [[MyOpenGLView alloc] init];
	// int* indexData;
	
	GetData getdata;
	//np = getdata.getNumberOfPlate();
	nv = getdata.getNumberOfVertices();
	plateData = getdata.getPlateData();
	
	verticesData = getdata.getVerticesData();
	
	printf("%d %lf\n",nv,verticesData[0][0]);
	
	
	[myopengl setPData:plateData];
	//[resultView setString:[arr2 copy]];
	 
	//[resultView setString:[[NSString
	//						stringWithContentsOfFile:filePath
	//						encoding:4 error:nil]copy]];
	
}

@end
