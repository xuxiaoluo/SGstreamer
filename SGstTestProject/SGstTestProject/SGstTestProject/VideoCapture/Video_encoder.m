//
//  Video_encoder.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/27.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "Video_encoder.h"

@implementation Video_encoder

+(GstElement *)encoder{

    GstElement *encoder = NULL;
    encoder = gst_element_factory_make("x264enc", NULL);
    g_object_set(G_OBJECT(encoder), "bitrate",400000,NULL);
    g_object_set(G_OBJECT(encoder), "byte-stream",true,NULL);
    g_object_set(G_OBJECT(encoder), "tune",4,NULL);
    g_object_set(G_OBJECT(encoder), "bframes",0,NULL);
    g_object_set(G_OBJECT(encoder), "aud",false,NULL);
    g_object_set(G_OBJECT(encoder), "speed-preset",3,NULL);
    g_object_set(G_OBJECT(encoder), "b-adapt",false,NULL);
    g_object_set(G_OBJECT(encoder), "b-pyramid",false,NULL);
    g_object_set(G_OBJECT(encoder), "ip-factor",1.0,NULL);
    g_object_set(G_OBJECT(encoder), "dct8x8",true,NULL);
    g_object_set(G_OBJECT(encoder), "weightb",false,NULL);
    g_object_set(G_OBJECT(encoder), "qp-min",18,NULL);
    g_object_set(G_OBJECT(encoder), "qp-max",48,NULL);
    g_object_set(G_OBJECT(encoder), "key-int-max",120,NULL);
    g_object_set(G_OBJECT(encoder), "ref",1,NULL);
    g_object_set(G_OBJECT(encoder), "option-string","weightp=0",NULL);
    g_object_set(G_OBJECT(encoder), "cabac",true,NULL);
    return encoder;
}


+(GstElement *)encoder_filter{
    GstElement *filter = NULL;
    GstCaps *encoder_caps;
    const gchar *encoder_str;
    filter  = gst_element_factory_make("capsfilter", NULL);
    encoder_str = "video/x-h264,format =(string) NV12,framerate = 20/1,width=(int)1280, height=(int)720,stream-format=(string)byte-stream,profile= (string)high,alignment = au";
    encoder_caps = gst_caps_from_string (encoder_str);
    g_object_set (G_OBJECT(filter), "caps", encoder_caps, NULL);
    return filter;
}


@end
