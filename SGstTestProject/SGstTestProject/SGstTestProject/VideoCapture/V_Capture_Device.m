//
//  V_Capture_Device.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/23.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "V_Capture_Device.h"
#import "S_Model.h"
@implementation V_Capture_Device

+(NSMutableArray *)Get_V_Capture_Device{
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSMutableArray *v_device_info = [NSMutableArray array];
    for (int i = 0; i < devices.count; i ++) {
        V_Device_Info *d_info = [[V_Device_Info alloc] init];
        if (@available(macOS 10.8, *)) {
            d_info.v_device = devices[i];
        } else {
            // Fallback on earlier versions
        }
        d_info.v_device_uniqueID = d_info.v_device.uniqueID;
        d_info.v_device_localizedName = d_info.v_device.localizedName;
        [v_device_info addObject:d_info];
    }
    return v_device_info;
}





@end
