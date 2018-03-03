//
//  Video_Decoder.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/26.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "Video_Decoder.h"
#include <gst/gst.h>
#include <gst/video/video.h>

@implementation Video_Decoder{
    
    GstElement *pipeline;
    GstElement *video_sink;
    GMainContext *context;
    GMainLoop *main_loop;
    gboolean initialized;
}

-(instancetype)init{
    if ([super init]) {
        
        setenv("GST_DEBUG", "5", 1);
        char *argv ="";
        gst_init(0, &argv);
        [self DecoderLocalFile:nil];
    }
    return self;
}

-(void)DecoderLocalFile:(NSString *)local_file{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self Decoder:local_file];
    });
}

-(void)start_decode{
    if(gst_element_set_state(pipeline, GST_STATE_PLAYING) == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Failed to start_decode");
    }
}
-(void)stop_decode{
    
    if(gst_element_set_state(pipeline, GST_STATE_PAUSED) == GST_STATE_CHANGE_FAILURE) {
        NSLog(@"Failed to stop_decode");
    }
    if (pipeline) {
        GST_DEBUG("Setting the pipeline to NULL");
        gst_element_set_state(pipeline, GST_STATE_NULL);
    }
}

-(void)Decoder:(NSString *)file_path{
    
    
    GstBus *bus;
    GSource *bus_source;
    GError *error = NULL;
    
    pipeline = gst_pipeline_new("decoder_pipeline");
    context = g_main_context_new();
    g_main_context_push_thread_default(context);

    GstElement *file_src,*decoder,*write_file,*encoder_file,*encoder,*write_encoder_file,*decoder_filter,*video_sink,*h264parse,*encode_h264parse,*videoconvert,*osxvideosink;
  
    // 读取本地文件
    file_src = gst_element_factory_make("filesrc", NULL);
    g_object_set(G_OBJECT(file_src), "location","/Users/sean/Desktop/gst_file/gst_write360.h264", nil);
    
    
//    h264parse 264解析器
    h264parse = gst_element_factory_make("h264parse", NULL);

    //创建解码器
    decoder = gst_element_factory_make("avdec_h264", NULL);
    
    //创建视频转换器
    videoconvert = gst_element_factory_make("videoconvert", NULL);
    
    // 显示视频
    osxvideosink = gst_element_factory_make("osxvideosink", NULL);
    
    
//     写本地360文件
    write_file= gst_element_factory_make("filesink", NULL);
    g_object_set(G_OBJECT(write_file), "append",true, nil);
    g_object_set(G_OBJECT(write_file), "location","/Users/sean/Desktop/gst_file/write_360.yuv", nil);
    
    gst_bin_add_many(GST_BIN(pipeline), file_src,h264parse,decoder,videoconvert,osxvideosink, nil);
    if (!gst_element_link_many(file_src,h264parse,decoder,videoconvert,osxvideosink, nil)) {
        NSLog(@"decoder link failed");
    }
    gst_element_set_state(pipeline,GST_STATE_READY);
    

    if (error) {
        gchar *message = g_strdup_printf("Unable to build pipeline: %s", error->message);
        g_clear_error (&error);
        //        [self setUIMessage:message];
        NSLog(@"start_function msg = %@",[NSString stringWithUTF8String:message]);
        g_free (message);
        return;
    }
    
    gst_element_set_state(pipeline, GST_STATE_READY);
    
//    video_sink = gst_bin_get_by_interface(GST_BIN(pipeline), GST_TYPE_VIDEO_OVERLAY);
//    if (!video_sink) {
//        GST_ERROR ("Could not retrieve video sink");
//        return;
//    }
    
    
    
    bus = gst_element_get_bus (pipeline);
    bus_source = gst_bus_create_watch (bus);
    g_source_set_callback (bus_source, (GSourceFunc) gst_bus_async_signal_func, NULL, NULL);
    g_source_attach (bus_source, context);
    g_source_unref (bus_source);
//    g_signal_connect (G_OBJECT (bus), "message::error", (GCallback)error_cb, (__bridge void *)self);
//    g_signal_connect (G_OBJECT (bus), "message::state-changed", (GCallback)state_changed_cb, (__bridge void *)self);
    gst_object_unref (bus);
    
    /* Create a GLib Main Loop and set it to run */
    GST_DEBUG ("Entering main loop...");
    main_loop = g_main_loop_new (context, FALSE);
    //    [self check_initialization_complete];
    g_main_loop_run (main_loop);
    GST_DEBUG ("Exited main loop");
    g_main_loop_unref (main_loop);
    main_loop = NULL;
    
    /* Free resources */
    g_main_context_pop_thread_default(context);
    g_main_context_unref (context);
    gst_element_set_state (pipeline, GST_STATE_NULL);
    gst_object_unref (pipeline);
    
    
}


@end
