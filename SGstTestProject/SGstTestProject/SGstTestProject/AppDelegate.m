//
//  AppDelegate.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/23.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "AppDelegate.h"
#import "VideoCapture.h"
#include <gst/gst.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    
    char *argv ="";
    gst_init(0, &argv);
    VideoCapture *v_capt_vc = [[VideoCapture alloc]initWithNibName:@"VideoCapture" bundle:nil];
    v_capt_vc.view.frame = self.window.contentView.bounds;
    [self.window.contentView addSubview:v_capt_vc.view];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
