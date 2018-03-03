//
//  AppDelegate.m
//  GST_Cap_Enc_file
//
//  Created by Sean on 2018/3/3.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "AppDelegate.h"
#import "GST_Cap_Enc_file.h"
#include <gst/gst.h>

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    char *argv ="";
    gst_init(0, &argv);

    GST_Cap_Enc_file *v_capt_vc = [[GST_Cap_Enc_file alloc]initWithNibName:@"GST_Cap_Enc_file" bundle:nil];
    v_capt_vc.view.frame = self.window.contentView.bounds;
    [self.window.contentView addSubview:v_capt_vc.view];
    
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
