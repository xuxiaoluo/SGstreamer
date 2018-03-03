//
//  Gst_Video_Capture.h
//  SGstTestProject
//
//  Created by Sean on 2018/2/23.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface Gst_Video_Capture : NSObject
-(NSString *)Get_gst_Version;

-(instancetype)initWithVideoView:(NSView *)videoView delegate:(id)delegate;
-(void)start_Capture;
-(void)stop_Capture;
@end
