//
//  VideoCapture.m
//  SGstTestProject
//
//  Created by Sean on 2018/2/23.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "VideoCapture.h"
#import "Gst_Video_Capture.h"
#import "V_Capture_Device.h"
#import "S_Model.h"
#import "Video_Decoder.h"

@interface VideoCapture ()
@property (strong, nonatomic)  Gst_Video_Capture *gst_capt_vc;
@property (strong, nonatomic) Video_Decoder *decoder;
@property (weak) IBOutlet NSView *localView;
@end

@implementation VideoCapture

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    for (V_Device_Info *d_info in [V_Capture_Device Get_V_Capture_Device]) {
        NSLog(@"d_info.locaname = %@",d_info.v_device_localizedName);
    }
     _gst_capt_vc = [[Gst_Video_Capture alloc] initWithVideoView:_localView delegate:self];
    NSLog(@"gst.version = %@",[_gst_capt_vc Get_gst_Version]);
    
    _decoder = [[Video_Decoder alloc] init];
    
}

- (IBAction)startBtnClicked:(id)sender {
    [_gst_capt_vc start_Capture];
}

- (IBAction)stopBtnClicked:(id)sender {
    [_gst_capt_vc stop_Capture];

}
- (IBAction)start_dec_clicked:(id)sender {
    
    [_decoder start_decode];
}
- (IBAction)stop_dec_clicked:(id)sender {
    [_decoder stop_decode];
}

@end
