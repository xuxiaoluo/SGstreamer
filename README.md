# SGstreamer
读16个文件->解码-〉显示 （1-16 （16:9） 每5秒切换显示方式）

Mac视频采集用 avfvideosrc 组件

Mac 视频软编码 x264enc 组件

Mac 视频硬编码 vtench264hw 组件

设置 allow-frame-reordering = false  取消编码b帧
软编码

gst-launch 命令行

视频采集、编码（x264enc）、写入本地（（cpu占用 72%））

gst-launch-1.0 avfvideosrc ! video/x-raw, format='(string)'NV12, width=1280, height=720,framerate=30/1 ! x264enc byte-stream=true bframes=0 speed-preset=3 b-adapt=false b-pyramid=false dct8x8=true key-int-max=1000000 bitrate=2048 ! video/x-h264,format ='(string)'NV12,framerate=30/1,width= 1280, height=720,stream-format='(string)'byte-stream,profile= '(string)'high ! filesink location="/Users/sean/Desktop/gst_file/x264_enc.h264"
//max-keyframe-interval=120 bitrate=400000 realtime=true

vtench264hw 硬件编码 （cpu占用 6.7%）

// realtime=true allow-frame-reordering=false

gst-launch-1.0 avfvideosrc ! video/x-raw, format='(string)'NV12, width=1280, height=720,framerate=30/1 ! vtenc_h264_hw allow-frame-reordering=false realtime=true bitrate=2048 quality=1 ! video/x-h264,width= 1280, height=720,framerate=30/1 ! h264parse ! video/x-h264,stream-format='(string)'byte-stream ! capsfilter caps=video/x-h264,profile=high ! filesink location="/Users/sean/Desktop/gst_file/vt_enc.h264"
软解码 (cpu 占用率 50% 上下)

gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/gst_write720.h264" ! h264parse ! avdec_h264 ! videoconvert ! osxvideosink
硬解码 (cpu 占用率24%)

gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/gst_write720.h264" ! h264parse ! video/x-h264,stream-format=avc ! vtdec_hw ! videoconvert ! osxvideosink
