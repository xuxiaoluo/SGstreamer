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
#include <gst/video/video.h>
#import "Video_Rect.h"
#import "NSView+Flipped.h"

#define VIEW_NUM 3
@interface VideoCapture ()
@property (strong, nonatomic)  Gst_Video_Capture *gst_capt_vc;
@property (strong, nonatomic) Video_Decoder *decoder;
@property (weak) IBOutlet NSView *localView;
@property (weak) IBOutlet NSView *nother_view;
@end

@implementation VideoCapture{
    GstElement *pipeline;
}



-(void)viewWillAppear{
    [super viewWillAppear];
    [self.view isFlipped];
}

- (BOOL)isFlipped{
    return YES;
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
    
    NSMutableArray *pad_arr = [NSMutableArray array];
    NSMutableArray *queue_arr = [NSMutableArray array];
    NSMutableArray *queue_pad_arr = [NSMutableArray array];
    NSMutableArray *video_sink_arr = [NSMutableArray array];
    NSMutableArray *video_convert_arr = [NSMutableArray array];
    NSMutableArray *view_arr = [NSMutableArray array];
    
    for (int i = 0; i < VIEW_NUM; i ++) {
        NSMutableArray *rect_arr =  [Video_Rect GetRectWithNum:VIEW_NUM andWidown:self.view];
        NSRect rect = [[rect_arr objectAtIndex:i]rectValue];
        NSView *view = [[NSView alloc] initWithFrame:rect];
        [view_arr addObject:view];
        [self.view addSubview:view];
    }
    
    
    
    pipeline = gst_pipeline_new("pipeline");
    GstElement *device = [Capture Capture_deviceInsertPipeline:pipeline];
    GstElement *device_filter = [Capture Capture_filterWithFrame:30 InsertPipeline:pipeline];
    

    GstElement *tee = gst_element_factory_make("tee", "tee");
    GstPadTemplate *src_pad_template = gst_element_class_get_pad_template (GST_ELEMENT_GET_CLASS (tee), "src_%u");
    
    
    gst_bin_add_many(GST_BIN(pipeline), device,device_filter,tee, nil);
    if(!gst_element_link_many(device, device_filter,tee, nil))
        NSLog(@"gst_element_link_many(device, device_filter,tee) failed");
    
    
    
    
    
    
    for (int i = 0; i < VIEW_NUM; i ++) {
       
        GstPad *src_pad = gst_element_request_pad(tee, src_pad_template, NULL, NULL);
        [pad_arr addObject:[NSValue value:&src_pad withObjCType:@encode(GstPad*)]];

        NSString *queuename = [NSString stringWithFormat:@"queue%d",i];
        GstElement *sink_queue = gst_element_factory_make ("queue", (const gchar *)[queuename UTF8String]);
        [queue_arr addObject:[NSValue value:&sink_queue withObjCType:@encode(GstElement *)]];

        GstPad *sink_queue_pad = gst_element_get_static_pad (sink_queue, "sink");
        [queue_pad_arr addObject:[NSValue value:&sink_queue_pad withObjCType:@encode(GstPad*)]];
    
        NSString *video_sink_name = [NSString stringWithFormat:@"video_sink%d",i];
        GstElement *video_sink = gst_element_factory_make("osxvideosink", (const gchar *)[video_sink_name UTF8String]);
        [video_sink_arr addObject:[NSValue value:&video_sink withObjCType:@encode(GstElement*)]];
        
        NSString *convert_name = [NSString stringWithFormat:@"convert_name%d",i];
        GstElement *convert = gst_element_factory_make("videoconvert", (const gchar *)[convert_name UTF8String]);
        [video_convert_arr addObject:[NSValue value:&convert withObjCType:@encode(GstElement*)]];
    }
    
    
//    gst_bin_add_many(GST_BIN(pipeline), device,device_filter,convert,video_sink, nil);
    
    
    for (int i = 0; i < VIEW_NUM; i ++) {
        
        GstElement *queue;
        [[queue_arr objectAtIndex:i] getValue:&queue];
        gst_bin_add_many(GST_BIN(pipeline),queue, nil);

        GstPad *tem_pad ;
        [[pad_arr objectAtIndex:i] getValue:&tem_pad];

        GstPad *queue_pad;
        [[queue_pad_arr objectAtIndex:i] getValue:&queue_pad];


        if(gst_pad_link(tem_pad, queue_pad) != GST_PAD_LINK_OK )
            NSLog(@"gst_pad_link(tem_pad, queue_pad) failed %d",i);
        gst_object_unref (queue_pad);
        
    
        gst_element_link(device_filter, tee);
        gst_element_link(tee, queue);
        
        GstElement *convert;
        [[video_convert_arr objectAtIndex:i] getValue:&convert];
        GstElement *video_sink;
        [[video_sink_arr objectAtIndex:i] getValue:&video_sink];

        
        gst_bin_add_many(GST_BIN(pipeline), convert, nil);
        gst_element_link(queue, convert);
        gst_bin_add_many(GST_BIN(pipeline), video_sink, nil);
       if(! gst_element_link_many(convert,video_sink, nil))
           NSLog(@"gst_element_link_many(queue, convert,video_sink, nil) failed %d",i);
    }

    

    
    for (int i = 0; i < VIEW_NUM; i ++) {
        GstElement *video_sink;
        [[video_sink_arr objectAtIndex:i] getValue:&video_sink];
//        video_sink = gst_bin_get_by_interface(GST_BIN(pipeline), GST_TYPE_VIDEO_OVERLAY);
        if (!video_sink) {
            GST_ERROR ("Could not retrieve video sink");
            return;
        }
        
        NSView *ui_view = [view_arr objectAtIndex:i];
        gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_sink), (guintptr) (id)ui_view);
//        if (i == 0) {
//            gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_sink), (guintptr) (id)self.localView);
//        }else {
//            gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_sink), (guintptr) (id)_nother_view);
//        }
        
    }
    
    gst_element_set_state(pipeline, GST_STATE_READY);
    if(gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Failed to set pipeline to start");
    }
    
    
    
    // 释放tee
//    for (int i = 0; i < VIEW_NUM; i ++) {
//        GstPad *tem_pad ;
//        [[pad_arr objectAtIndex:i] getValue:&tem_pad];
//        gst_element_release_request_pad (tee, tem_pad);
//        gst_object_unref (tem_pad);
//    }
   
    
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
