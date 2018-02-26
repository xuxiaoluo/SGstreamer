//
//  Gst_Video_Capture.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/23.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "Gst_Video_Capture.h"
#include <gst/gst.h>
#include <gst/video/video.h>
#include <gst/check/gstcheck.h>


#import "V_Capture_Device.h"

GST_DEBUG_CATEGORY_STATIC (debug_category);
#define GST_CAT_DEFAULT debug_category

@interface Gst_Video_Capture()
@end

@implementation Gst_Video_Capture{
    NSView *v_view;
    id ui_delegate;
    GstElement *pipeline;
    GstElement *video_sink;
    GMainContext *context;
    GMainLoop *main_loop;
    gboolean initialized;
    
}

-(NSString *)Get_gst_Version{
    char *version_utf8 = gst_version_string();
    NSString *version_string = [NSString stringWithUTF8String:version_utf8];
    g_free(version_utf8);
    return version_string;
}


-(instancetype)initWithVideoView:(NSView *)videoView delegate:(id)delegate{
    
    if ([super init]) {
        self->v_view = videoView;
        self->ui_delegate = delegate;
        
        char *argv ="";
        gst_init(0, &argv);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self app_function];
        });
    }
    
    return self;

}

/* Retrieve errors from the bus and show them on the UI */
static void error_cb (GstBus *bus, GstMessage *msg, Gst_Video_Capture *self)
{
    GError *err;
    gchar *debug_info;
    gchar *message_string;
    
    gst_message_parse_error (msg, &err, &debug_info);
    message_string = g_strdup_printf ("Error received from element %s: %s", GST_OBJECT_NAME (msg->src), err->message);
    g_clear_error (&err);
    g_free (debug_info);
//    [self setUIMessage:message_string];
    
    NSLog(@"error_cb msg = %@",[NSString stringWithUTF8String:message_string]);
    
    g_free (message_string);
    gst_element_set_state (self->pipeline, GST_STATE_NULL);
}

/* Notify UI about pipeline state changes */
static void state_changed_cb (GstBus *bus, GstMessage *msg, Gst_Video_Capture *self)
{
    GstState old_state, new_state, pending_state;
    gst_message_parse_state_changed (msg, &old_state, &new_state, &pending_state);
    /* Only pay attention to messages coming from the pipeline, not its children */
    if (GST_MESSAGE_SRC (msg) == GST_OBJECT (self->pipeline)) {
        gchar *message = g_strdup_printf("State changed to %s", gst_element_state_get_name(new_state));
//        [self setUIMessage:message];
         NSLog(@"state_changed_cb msg = %@",[NSString stringWithUTF8String:message]);
        g_free (message);
    }
    
    
}


-(void)start_Capture{
    if(gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Failed to set pipeline to start");
    }

}
-(void)stop_Capture{
    if(gst_element_set_state(pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Failed to set pipeline to stop");
    }

    if (pipeline) {
        GST_DEBUG("Setting the pipeline to NULL");
        gst_element_set_state(pipeline, GST_STATE_NULL);
//        gst_object_unref(pipeline);
//        pipeline = NULL;
    }

}


-(void)app_function{
    
    GstBus *bus;
    GSource *bus_source;
    GError *error = NULL;
    
    GstElement *input_device, *encdoer, *local_file,*filter,*tee, *seven_queue,*three_queue;
    GstCaps *filter_caps;
    const gchar *caps_str;
    
    
  
    
    
    context = g_main_context_new();
    g_main_context_push_thread_default(context);
    
    
    pipeline = gst_pipeline_new("pipeline");
    
    
   input_device  = gst_element_factory_make("avfvideosrc", "v_capture");
    // 指定采集设备 设置采集参数
    g_object_set(G_OBJECT(input_device),"device-index", 0, NULL);
    g_object_set(G_OBJECT(input_device),"position", 0, NULL);
    g_object_set(G_OBJECT(input_device),"name","video_capture", NULL);

    filter = gst_element_factory_make("capsfilter", "capture_filter");
    caps_str = "video/x-raw, format =(string) NV12,framerate = 30/1,width=(int)1280, height=(int)720";
    filter_caps = gst_caps_from_string (caps_str);
    g_object_set (G_OBJECT(filter), "caps", filter_caps, NULL);
    
    
    // 视频缩放组件
    GstElement * V_Scale_Element_720,*scale_filter_720;
    V_Scale_Element_720 = gst_element_factory_make("videoscale", NULL);
    g_object_set(G_OBJECT(V_Scale_Element_720), "name","V_Scale_Element_720", nil);
    g_object_set(G_OBJECT(V_Scale_Element_720), "add-borders",true, nil);
    g_object_set(G_OBJECT(V_Scale_Element_720), "sharpness",1.0, nil);
    
    scale_filter_720 = gst_element_factory_make("capsfilter", "scale_filter_720");
    GstCaps *scale_caps_720;
    const gchar *scale_str_720;
    // 将720缩放为360
    scale_str_720 = "video/x-raw,format =(string) NV12,framerate = 30/1,width=(int)1280, height=(int)720";
    scale_caps_720 = gst_caps_from_string (scale_str_720);
    g_object_set (G_OBJECT(scale_filter_720), "caps", scale_caps_720, NULL);
    
    
    
    GstElement * V_Scale_Element_360,*scale_filter_360;
    V_Scale_Element_360 = gst_element_factory_make("videoscale", NULL);
    g_object_set(G_OBJECT(V_Scale_Element_360), "name","V_Scale_Element_360", nil);
    g_object_set(G_OBJECT(V_Scale_Element_360), "add-borders",true, nil);
    g_object_set(G_OBJECT(V_Scale_Element_360), "sharpness",1.0, nil);
    
    scale_filter_360 = gst_element_factory_make("capsfilter", "scale_filter_360");
    GstCaps *scale_caps_360;
    const gchar *scale_str_360;
    // 将720缩放为360
    scale_str_360 = "video/x-raw,format =(string) NV12,framerate = 30/1,width=(int)320, height=(int)180";
    scale_caps_360 = gst_caps_from_string (scale_str_360);
    g_object_set (G_OBJECT(scale_filter_360), "caps", scale_caps_360, NULL);
    
    
    
    /*
     创建编码器 设置编码参数
     720 编码器属性设置
     */
    GstElement *seven_encoder,*seven_filter;
    GstCaps *seven_encoder_caps;
    const gchar *seven_encoder_str;
    seven_encoder = gst_element_factory_make("x264enc",NULL);
    g_object_set(G_OBJECT(seven_encoder), "name","sevenencoder", NULL);
    g_object_set(G_OBJECT(seven_encoder), "bitrate",400000,NULL);
    g_object_set(G_OBJECT(seven_encoder), "byte-stream",true,NULL);
    g_object_set(G_OBJECT(seven_encoder), "tune",4,NULL);
    g_object_set(G_OBJECT(seven_encoder), "bframes",0,NULL);
    g_object_set(G_OBJECT(seven_encoder), "aud",false,NULL);
    g_object_set(G_OBJECT(seven_encoder), "speed-preset",3,NULL);
    g_object_set(G_OBJECT(seven_encoder), "b-adapt",false,NULL);
    g_object_set(G_OBJECT(seven_encoder), "b-pyramid",false,NULL);
    g_object_set(G_OBJECT(seven_encoder), "ip-factor",1.0,NULL);
    g_object_set(G_OBJECT(seven_encoder), "dct8x8",true,NULL);
    g_object_set(G_OBJECT(seven_encoder), "weightb",false,NULL);
    g_object_set(G_OBJECT(seven_encoder), "qp-min",18,NULL);
    g_object_set(G_OBJECT(seven_encoder), "qp-max",48,NULL);
    g_object_set(G_OBJECT(seven_encoder), "key-int-max",20,NULL);
    g_object_set(G_OBJECT(seven_encoder), "ref",1,NULL);
    g_object_set(G_OBJECT(seven_encoder), "option-string","weightp=0",NULL);
    g_object_set(G_OBJECT(seven_encoder), "cabac",true,NULL);
    
    
    
//    seven_filter  = gst_element_factory_make("capsfilter", NULL);
//    seven_encoder_str = "video/x-h264,format =(string) NV12,framerate = 20/1,width=(int)1280, height=(int)720,stream-format=(string)byte-stream,profile= (string)high";
//    seven_encoder_caps = gst_caps_from_string (seven_encoder_str);
//    g_object_set (G_OBJECT(seven_filter), "caps", seven_encoder_caps, NULL);
    
    
    /*
     创建编码器 设置编码参数
     360 编码器属性设置
     */
    GstElement *three_encoder,*three_filter;
    GstCaps *three_encoder_caps;
    const gchar *three_encoder_str;
    
    three_encoder = gst_element_factory_make("x264enc", NULL);
    g_object_set(G_OBJECT(three_encoder), "name","three264encoder", NULL);
    g_object_set(G_OBJECT(three_encoder), "bitrate",400000,NULL);
    g_object_set(G_OBJECT(three_encoder), "byte-stream",true,NULL);
    g_object_set(G_OBJECT(three_encoder), "tune",4,NULL);
    g_object_set(G_OBJECT(three_encoder), "bframes",0,NULL);
    g_object_set(G_OBJECT(three_encoder), "aud",false,NULL);
    g_object_set(G_OBJECT(three_encoder), "speed-preset",3,NULL);
    g_object_set(G_OBJECT(three_encoder), "b-adapt",false,NULL);
    g_object_set(G_OBJECT(three_encoder), "b-pyramid",false,NULL);
    g_object_set(G_OBJECT(three_encoder), "ip-factor",1.0,NULL);
    g_object_set(G_OBJECT(three_encoder), "dct8x8",true,NULL);
    g_object_set(G_OBJECT(three_encoder), "weightb",false,NULL);
    g_object_set(G_OBJECT(three_encoder), "qp-min",18,NULL);
    g_object_set(G_OBJECT(three_encoder), "qp-max",48,NULL);
    g_object_set(G_OBJECT(three_encoder), "key-int-max",120,NULL);
    g_object_set(G_OBJECT(three_encoder), "ref",1,NULL);
    g_object_set(G_OBJECT(three_encoder), "option-string","weightp=0",NULL);
    g_object_set(G_OBJECT(three_encoder), "cabac",true,NULL);
    
    
//    three_filter  = gst_element_factory_make("capsfilter", NULL);
//    three_encoder_str = "video/x-h264,format =(string) NV12,framerate = 30/1,width=(int)640, height=(int)360,stream-format=(string)byte-stream,profile= (string)high";
//    three_encoder_caps = gst_caps_from_string (three_encoder_str);
//    g_object_set (G_OBJECT(three_filter), "caps", three_encoder_caps, NULL);
    

    
    // 写本地文件
    local_file = gst_element_factory_make("filesink", NULL);
    g_object_set(G_OBJECT(local_file), "name","sevenlocalfile", nil);
    g_object_set(G_OBJECT(local_file), "append",true, nil);
    g_object_set(G_OBJECT(local_file), "location","/Users/sean/Desktop/gst_file/gst_write720.h264", nil);

    
    // 写本地360文件
   GstElement *three_local_file = gst_element_factory_make("filesink", NULL);
    g_object_set(G_OBJECT(three_local_file), "name","threelocalfile", nil);
    g_object_set(G_OBJECT(three_local_file), "append",true, nil);
    g_object_set(G_OBJECT(three_local_file), "location","/Users/sean/Desktop/gst_file/gst_write360.h264", nil);
    
    
    
 
    
    
    
    
    GstPadTemplate *tee_src_pad_template;
    GstPad *tee_seven_pad, *tee_three_pad;
    GstPad *queue_seven_pad, *queue_three_pad;
    
    // 创建tee
    tee = gst_element_factory_make("tee", "tee");
    seven_queue = gst_element_factory_make ("queue", "seven_queue");
    three_queue = gst_element_factory_make ("queue", "three_queue");
    
    tee_src_pad_template = gst_element_class_get_pad_template (GST_ELEMENT_GET_CLASS (tee), "src_%u");
    // 720
    tee_seven_pad = gst_element_request_pad(tee, tee_src_pad_template, NULL, NULL);
    queue_seven_pad =  gst_element_get_static_pad (seven_queue, "sink");
    // 360
    tee_three_pad = gst_element_request_pad(tee, tee_src_pad_template, NULL, NULL);
    queue_three_pad =  gst_element_get_static_pad (three_queue, "sink");
    
    
    

    // 加到pipeline中 //,seven_filter //,three_filter
    gst_bin_add_many(GST_BIN(pipeline), input_device,filter,tee,seven_queue,V_Scale_Element_720,scale_filter_720,seven_encoder,local_file,three_queue,V_Scale_Element_360,scale_filter_360,three_encoder,three_local_file, NULL);
    
    // 链接tee和queue
    if (gst_pad_link (tee_seven_pad, queue_seven_pad) != GST_PAD_LINK_OK ||
        gst_pad_link (tee_three_pad, queue_three_pad) != GST_PAD_LINK_OK) {
        NSLog(@"gst_pad_link failed");
        gst_object_unref (pipeline);
    }
    gst_object_unref (queue_seven_pad);
    gst_object_unref (queue_three_pad);

    
    
    //链接tee
    if(!gst_element_link_many(input_device,filter,tee, NULL)){
        NSLog(@"tee gst_element_link_many failed");
    }
    
    //链接组件
    
    
    if (!gst_element_link_many(seven_queue,V_Scale_Element_720,scale_filter_720,seven_encoder,local_file, NULL)) {
        NSLog(@"seven gst_element_link_many failed");
    }
    
    if (!gst_element_link_many(three_queue,V_Scale_Element_360,scale_filter_360,three_encoder,three_local_file, NULL)) {
          NSLog(@"three gst_element_link_many failed");
    }
    
    
    

    GST_DEBUG ("Creating pipeline");
    
    
    if (error) {
        gchar *message = g_strdup_printf("Unable to build pipeline: %s", error->message);
        g_clear_error (&error);
//        [self setUIMessage:message];
        NSLog(@"start_function msg = %@",[NSString stringWithUTF8String:message]);
        g_free (message);
        return;
    }

     gst_element_set_state(pipeline, GST_STATE_READY);
    
     video_sink = gst_bin_get_by_interface(GST_BIN(pipeline), GST_TYPE_VIDEO_OVERLAY);
    if (!video_sink) {
        GST_ERROR ("Could not retrieve video sink");
        return;
    }
//    gst_video_overlay_set_window_handle(GST_VIDEO_OVERLAY(video_sink), (guintptr) (id) v_view);
    
    bus = gst_element_get_bus (pipeline);
    bus_source = gst_bus_create_watch (bus);
    g_source_set_callback (bus_source, (GSourceFunc) gst_bus_async_signal_func, NULL, NULL);
    g_source_attach (bus_source, context);
    g_source_unref (bus_source);
    g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)error_cb, (__bridge void *)self);
    g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)state_changed_cb, (__bridge void *)self);
    gst_object_unref (bus);
    
    /* Create a GLib Main Loop and set it to run */
    GST_DEBUG ("Entering main loop...");
    main_loop = g_main_loop_new (context, FALSE);
//    [self check_initialization_complete];
    g_main_loop_run (main_loop);
    GST_DEBUG ("Exited main loop");
    g_main_loop_unref (main_loop);
    main_loop = NULL;
    
    // 释放tee
    gst_element_release_request_pad (tee, tee_seven_pad);
    gst_element_release_request_pad (tee, tee_three_pad);
    gst_object_unref (tee_seven_pad);
    gst_object_unref (tee_three_pad);
    
    /* Free resources */
    g_main_context_pop_thread_default(context);
    g_main_context_unref (context);
    gst_element_set_state (pipeline, GST_STATE_NULL);
    gst_object_unref (pipeline);
    
}

-(void)dealloc{
    if (pipeline) {
        GST_DEBUG("Setting the pipeline to NULL");
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(pipeline);
        pipeline = NULL;
    }
    
}

@end
