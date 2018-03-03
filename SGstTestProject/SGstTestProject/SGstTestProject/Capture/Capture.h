//
//  Capture.h
//  SGstTestProject
//
//  Created by Sean on 2018/2/26.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <gst/gst.h>
@interface Capture : NSObject

+(GstElement *)Capture_deviceInsertPipeline:(GstElement *)pipeline;
+(GstElement *)Capture_filterWithFrame:(int)frameRate InsertPipeline:(GstElement *)pipeline;
@end
