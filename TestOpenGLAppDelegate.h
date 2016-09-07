//
//  TestOpenGLAppDelegate.h
//  TestOpenGL
//
//  Created by Toshihiro Harada on 12/02/19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TestOpenGLAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *__strong window;
}

@property (strong) IBOutlet NSWindow *window;

@end
