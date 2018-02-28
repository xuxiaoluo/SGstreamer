//
//  VideoCapture.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/23.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "VideoCapture.h"
#import "Gst_Video_Capture.h"
#import "V_Capture_Device.h"
#import "S_Model.h"
#import "Video_Decoder.h"
#include <gst/gst.h>
#include "Capture.h"
#include "Video_Scale.h"

@interface VideoCapture ()
@property (strong, nonatomic)  Gst_Video_Capture *gst_capt_vc;
@property (strong, nonatomic) Video_Decoder *decoder;
@property (weak) IBOutlet NSView *localView;
@end

@implementation VideoCapture{
    GstElement *pipeline;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
//    for (V_Device_Info *d_info in [V_Capture_Device Get_V_Capture_Device]) {
//        NSLog(@"d_info.locaname = %@",d_info.v_device_localizedName);
//    }
//     _gst_capt_vc = [[Gst_Video_Capture alloc] initWithVideoView:_localView delegate:self];
//    NSLog(@"gst.version = %@",[_gst_capt_vc Get_gst_Version]);
//
//    _decoder = [[Video_Decoder alloc] init];
    
    
    
    pipeline = gst_pipeline_new("pipeline");
    
    GstElement *device = [Capture Capture_device];
    GstElement *device_filter = [Capture Capture_filterWith:30];
    
    GstElement *scale = [Video_Scale Scale_element];
    GstElement *scale_filter = [Video_Scale scale_filter:640 andHeight:360];
    
    gst_bin_add_many(GST_BIN(pipeline), device,device_filter,scale,scale_filter, nil);
    gst_element_link_many(device, device_filter,scale,scale_filter, nil);
    
    
    
    for (int i = 0; i < 16; i ++) {
        // 写本地文件
        GstElement *local_file = gst_element_factory_make("filesink", NULL);
//        g_object_set(G_OBJECT(local_file), "name","sevenlocalfile", nil);
        g_object_set(G_OBJECT(local_file), "append",true, nil);
        NSString *str = [NSString stringWithFormat:@"/Users/sean/Desktop/gst_file/gst_write%d.h264",i + 1];
        g_object_set(G_OBJECT(local_file), "location",(const gchar *)[str UTF8String], nil);
        gst_bin_add_many(GST_BIN(pipeline),local_file, nil);
    }
    gst_element_set_state(pipeline, GST_STATE_READY);
}



- (IBAction)startBtnClicked:(id)sender {
//    [_gst_capt_vc start_Capture];
    
    if(gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Failed to set pipeline to start");
    }
}



- (IBAction)stopBtnClicked:(id)sender {
//    [_gst_capt_vc stop_Capture];
    if(gst_element_set_state(pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Failed to set pipeline to stop");
    }
    
    if (pipeline) {
        GST_DEBUG("Setting the pipeline to NULL");
        gst_element_set_state(pipeline, GST_STATE_NULL);
    }

}
- (IBAction)start_dec_clicked:(id)sender {
    
    [_decoder start_decode];
}
- (IBAction)stop_dec_clicked:(id)sender {
    [_decoder stop_decode];
}

@end
