//
//  S_Model.h
//  SGstTestProject
//
//  Created by Sean on 2018/2/23.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface S_Model : NSObject
@end

@interface V_Device_Info:NSObject
@property (strong, nonatomic) AVCaptureDevice *v_device;
@property (strong, nonatomic) NSString *v_device_uniqueID;
@property (strong, nonatomic) NSString *v_device_localizedName;
@end
