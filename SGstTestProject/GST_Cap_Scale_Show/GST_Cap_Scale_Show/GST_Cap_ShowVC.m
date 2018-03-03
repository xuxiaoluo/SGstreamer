//
//  GST_Cap_ShowVC.m
//  GST_Cap_Scale_Show
//
//  Created by Sean on 2018/3/2.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "GST_Cap_ShowVC.h"
#import "Capture.h"
#import "Video_Scale.h"
#include <gst/video/video.h>


@interface GST_Cap_ShowVC ()
@property (weak) IBOutlet NSView *highView;
@property (weak) IBOutlet NSView *lowView;

@end

@implementation GST_Cap_ShowVC{
    
    GstElement *pipeline;
    GstElement *tee;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    pipeline = gst_pipeline_new("capPipeline");
    
    GstElement *cap_element = [Capture Capture_deviceInsertPipeline:pipeline];
    GstElement *cap_filter = [Capture Capture_filterWithFrame:30 InsertPipeline:pipeline];
    gst_element_link(cap_element, cap_filter);
    
    
    tee = gst_element_factory_make("tee", "tee");
    gst_bin_add(GST_BIN(pipeline), tee);
    gst_element_link(cap_filter, tee);
    
    
    GstPadTemplate *src_pad_template = gst_element_class_get_pad_template (GST_ELEMENT_GET_CLASS (tee), "src_%u");
    
    GstPad *src_high_pad = gst_element_request_pad(tee, src_pad_template, NULL, NULL);
    GstPad *src_low_pad = gst_element_request_pad(tee, src_pad_template, NULL, NULL);
    
    
    NSString *high_queuename = [NSString stringWithFormat:@"high_queue"];
    GstElement *sink_high_queue = gst_element_factory_make ("queue", (const gchar *)[high_queuename UTF8String]);
    gst_bin_add(GST_BIN(pipeline), sink_high_queue);
    
    NSString *low_queuename = [NSString stringWithFormat:@"low_queue"];
    GstElement *sink_low_queue = gst_element_factory_make ("queue", (const gchar *)[low_queuename UTF8String]);
    gst_bin_add(GST_BIN(pipeline), sink_low_queue);
    
    GstPad *sink_high_pad = gst_element_get_static_pad (sink_high_queue, "sink");
    GstPad *sink_low_pad = gst_element_get_static_pad (sink_low_queue, "sink");
    
    gst_pad_link(src_high_pad, sink_high_pad);
    gst_object_unref (sink_high_pad);
    gst_pad_link(src_low_pad, sink_low_pad);
    gst_object_unref (sink_low_pad);
    
    gst_element_link(tee, sink_high_queue);
    gst_element_link(tee, sink_low_queue);
    
    GstElement *scale_high_element = [Video_Scale Scale_elementInsertPipeline:pipeline];
    GstElement *scale_high_filter = [Video_Scale scale_filterWidth:640 andHeight:360 InsertPipeline:pipeline];
    gst_element_link_many(sink_high_queue, scale_high_element,scale_high_filter, nil);
    
    GstElement *scale_low_element = [Video_Scale Scale_elementInsertPipeline:pipeline];
    GstElement *scale_low_filter = [Video_Scale scale_filterWidth:320 andHeight:180 InsertPipeline:pipeline];
    gst_element_link_many(sink_low_queue, scale_low_element,scale_low_filter, nil);
    
    
    NSString *convert_high_name = [NSString stringWithFormat:@"convert_high"];
    GstElement *convert_high = gst_element_factory_make("videoconvert", (const gchar *)[convert_high_name UTF8String]);
    gst_bin_add(GST_BIN(pipeline), convert_high);
    
    gst_element_link(scale_high_filter, convert_high);
    
    NSString *convert_low_name = [NSString stringWithFormat:@"convert_low_name"];
    GstElement *convert_low = gst_element_factory_make("videoconvert", (const gchar *)[convert_low_name UTF8String]);
    gst_bin_add(GST_BIN(pipeline), convert_low);
    gst_element_link(scale_low_filter, convert_low);
    
    
    
    NSString *video_high_sink_name = [NSString stringWithFormat:@"video_high_sink"];
    GstElement *video_high_sink = gst_element_factory_make("osxvideosink", (const gchar *)[video_high_sink_name UTF8String]);
    
    gst_bin_add(GST_BIN(pipeline), video_high_sink);
    gst_element_link(convert_high, video_high_sink);
    
    
    NSString *video_low_sink_name = [NSString stringWithFormat:@"video_low_sink"];
    GstElement *video_low_sink = gst_element_factory_make("osxvideosink", (const gchar *)[video_low_sink_name UTF8String]);
    gst_bin_add(GST_BIN(pipeline), video_low_sink);
    gst_element_link(convert_low, video_low_sink);
    
    gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_high_sink), (guintptr) (id)self.highView);
    gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_low_sink), (guintptr) (id)self.lowView);
    gst_element_set_state(pipeline, GST_STATE_READY);
    if(gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Failed to set pipeline to start");
    }

}

@end
