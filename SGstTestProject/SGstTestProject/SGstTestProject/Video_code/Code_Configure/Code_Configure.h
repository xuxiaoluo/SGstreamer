//
//  Code_Configure.h
//  SGstTestProject
//
//  Created by Sean on 2018/2/27.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Code_Configure : NSObject

@end

@interface Code_Encode_Con:NSObject

/*
 Kbps
 default:400
 */
@property (assign, nonatomic) int *bitrate;

/*
I 帧间隔
default：120
 */
@property (assign, nonatomic) int max_gop;

/*
 帧率
 default：30
 */
@property (assign, nonatomic) int framerate;




@end
