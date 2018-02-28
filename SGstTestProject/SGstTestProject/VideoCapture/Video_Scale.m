//
//  Video_Scale.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/26.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "Video_Scale.h"

@implementation Video_Scale

+(GstElement *)Scale_element{
    GstElement * scale_video;
    scale_video = gst_element_factory_make("videoscale", NULL);
    g_object_set(G_OBJECT(scale_video), "add-borders",true, nil);
    g_object_set(G_OBJECT(scale_video), "sharpness",1.0, nil);
    return scale_video;
}


+(GstElement *)scale_filter:(int)width andHeight:(int)height{
    GstElement * scale_filter;
    scale_filter = gst_element_factory_make("capsfilter", NULL);
    GstCaps *scale_caps;
    const gchar *scale_str;
    NSString *str = [NSString stringWithFormat:@"video/x-raw,format =(string) NV12,framerate = 30/1,width=(int)%d, height=(int)%d",width,height];
    scale_str = (const gchar*) [str UTF8String];
    scale_caps = gst_caps_from_string (scale_str);
    g_object_set (G_OBJECT(scale_filter), "caps", scale_caps, NULL);
    return scale_filter;
}
@end
