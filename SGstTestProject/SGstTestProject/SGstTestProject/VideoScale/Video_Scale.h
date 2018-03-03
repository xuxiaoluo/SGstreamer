//
//  Video_Scale.h
//  SGstTestProject
//
//  Created by Sean on 2018/2/26.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <gst/gst.h>

@interface Video_Scale : NSObject
+(GstElement *)Scale_elementInsertPipeline:(GstElement *)pipeline;
+(GstElement *)scale_filterWidth:(int)width andHeight:(int)height InsertPipeline:(GstElement *)pipeline;
@end
