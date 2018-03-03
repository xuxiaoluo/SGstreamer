//
//  Video_Rect.m
//  SGstTestProject
//
//  Created by Sean on 2018/3/1.
//  Copyright © 2018年 Sean. All rights reserved.
//

#import "Video_Rect.h"


@implementation Video_Rect
+(NSMutableArray *)GetRectWithNum:(int)num andWidown:(NSView *)win_view{
    
    if (num == 0) {
        return nil;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    float window_width = win_view.bounds.size.width;
    float window_height = win_view.bounds.size.height;
    if (num == 1) {
        NSRect rect = NSMakeRect(0, 0, window_width, window_height);
        [arr addObject:[NSValue valueWithRect:rect]];
        return arr;
    }
    
    if (num == 2) {
        for (int i = 0; i < num; i ++) {
            NSRect rect;
            float wid = window_width/2;
            float height = (wid * 9)/16;
            rect = NSMakeRect(i* window_width/2, window_height/2 - height/2, wid, height);
            [arr addObject:[NSValue valueWithRect:rect]];
        }
        return arr;
    }
    
    if (num == 3) {
        for (int i = 0; i < num; i ++) {
            float wid = window_width/2;
            float height = (wid * 9)/16;
            NSRect rect = CGRectZero;
            if (i == 0) {
                rect = NSMakeRect( window_width/2 - wid/2, 0, wid, height);
            }else{
                rect = NSMakeRect((i-1) *  wid, window_height/2, wid, height);
            }
            [arr addObject:[NSValue valueWithRect:rect]];
        }
        return arr;
    }
    
    if (num == 4) {
        int k = 0;
        for (int i = 0; i < num; i ++) {
            float wid = window_width/2;
            float height = (wid * 9)/16;
            NSRect rect = CGRectZero;
            if (i != 0 && i % 2 ==0) {
                k ++;
            }
            if (k > 0) {
                rect = NSMakeRect((i -2) * wid, window_height/2, wid, height);
            }else
                 rect = NSMakeRect(i * wid, 0, wid, height);
            
            [arr addObject:[NSValue valueWithRect:rect]];
        }
        return arr;
    }
    return arr;
}
@end
