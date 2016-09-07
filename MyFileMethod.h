//
//  MyFileMethod.h
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/02/19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "SpiceUsr.h"
#include "SpiceDLA.h"
#include "SpiceDSK.h"
#import "GetData.h"
#import "MyOpenGLView.h"


@interface MyFileMethod : NSObject {

	IBOutlet NSTextView *resultView;
	IBOutlet NSButton *openButton;
	
	NSMutableArray *indexData;
	MyOpenGLView *myopengl;
}

-(IBAction)readFromFile:(id)sender;
//-(void)writeToFile:(id)sender;

@end
