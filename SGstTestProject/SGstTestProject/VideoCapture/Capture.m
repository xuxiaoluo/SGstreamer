//
//  Capture.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/26.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "Capture.h"


@implementation Capture

+(GstElement *)Capture_device{
    GstElement *input_device;
    input_device  = gst_element_factory_make("avfvideosrc", "v_capture");
    // 指定采集设备 设置采集参数
    g_object_set(G_OBJECT(input_device),"device-index", 0, NULL);
    g_object_set(G_OBJECT(input_device),"position", 0, NULL);
    g_object_set(G_OBJECT(input_device),"name","video_capture", NULL);
    return input_device;

}

+(GstElement *)Capture_filterWith:(int)frameRate{
    GstElement *filter;
    GstCaps *filter_caps;
    const gchar *caps_str;
    NSString *str = [NSString stringWithFormat:@"video/x-raw, format =(string) NV12,framerate = %d/1,width=(int)1280, height=(int)720",frameRate];
    filter = gst_element_factory_make("capsfilter", "capture_filter");
    caps_str =  (const gchar *)[str UTF8String];
    filter_caps = gst_caps_from_string (caps_str);
    g_object_set (G_OBJECT(filter), "caps", filter_caps, NULL);
    return filter;
}



@end
