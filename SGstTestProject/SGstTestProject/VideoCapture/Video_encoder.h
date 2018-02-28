//
//  Video_encoder.h
//  SGstTestProject
//
//  Created by Sean on 2018/2/27.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <gst/gst.h>

@interface Video_encoder : NSObject
+(GstElement *)encoder;
+(GstElement *)encoder_filter;
@end
