//
//  SetupWindowController.h
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/05/20.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SetupWindowController : NSObject {

	IBOutlet NSButton *fromFileCheckBox;
	IBOutlet NSButton *trajFileReferenceButton;
	IBOutlet NSTextField *trajFileTextField;
	
	
	
}
-(id)initWithFrame:(NSRect)frameRect;

-(void)checkBoxCont:(id)sender;

@end
