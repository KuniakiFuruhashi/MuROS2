//
//  ArrayClass.m
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/05/25.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ArrayClass.h"


@implementation ArrayClass
@synthesize array;
@synthesize a,b;



-(id)init{
	
	self = [super init];
	return [self initWithSetup:3 int:3];
	
	
}

-(id)initWithSetup:(int)aa int:(int)bb
{
	a = aa;
	b = bb;
	if (self) {
		array = (double**)malloc(sizeof(double*)*a);
		for (int i = 0; i < a; i++) {
			array[i] = (double*)malloc(sizeof(double)*b);
		}
	}
	
	return self;
	
}
-(void)dealloc {
	for (int i = 0 ; i < a; i++) {
		free(array[i]);
	}
	free(array);
	[super dealloc];
}

@end
