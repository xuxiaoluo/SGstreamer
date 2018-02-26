//
//  Video_Decoder.h
//  SGstTestProject
//
//  Created by Sean on 2018/2/26.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Video_Decoder : NSObject

-(instancetype)init;
-(void)DecoderLocalFile:(NSString *)local_file;
-(void)start_decode;
-(void)stop_decode;
@end
