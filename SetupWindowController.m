//
//  SetupWindowController.m
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/05/20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SetupWindowController.h"


@implementation SetupWindowController



-(id)initWithFrame:(NSRect)frameRect
{
	return self;
}

-(void)checkBoxCont:(id)sender
{
	//printf("%d\n",[fromFileCheckBox state]);
	
	if ([fromFileCheckBox state] == TRUE) {
		[trajFileTextField setHidden:FALSE];
		[trajFileReferenceButton setHidden:FALSE];
	}
	else if([fromFileCheckBox state] == FALSE) {
		[trajFileTextField setHidden:TRUE];
		[trajFileReferenceButton setHidden:TRUE];
		
	}
	
}


@end
