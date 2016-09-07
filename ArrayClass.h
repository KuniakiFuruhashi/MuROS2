//
//  ArrayClass.h
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/05/25.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ArrayClass : NSObject {

	double **array;
	int a,b;
}

@property(nonatomic, readonly)double **array;
@property(readwrite)int a,b;

-(id)initWithSetup:(int)aa int:(int)bb;
@end
