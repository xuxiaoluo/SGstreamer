# SGstreamer

##视频
    采集-->缩放(两路)-->编码-->解码-->显示(合成器：compositor)；
    
* 采集显示 1路 videosink
* 编码 采集一路-》缩放两路-〉编两路-〉存文件
* 解码 读文件（264文件）-》显示1路



###gst-launch 命令行

* 视频采集
     
        gst-launch-1.0 avfvideosrc ! videoconvert ! osxvideosink
     
* 软编码（x264enc）、写入本地（（cpu占用 72%））

        gst-launch-1.0 avfvideosrc ! video/x-raw, format='(string)'NV12, width=1280, height=720,framerate=30/1 ! x264enc byte-stream=true bframes=0 speed-preset=3 b-adapt=false b-pyramid=false dct8x8=true key-int-max=1000000 bitrate=2048 ! video/x-h264,format ='(string)'NV12,framerate=30/1,width= 1280, height=720,stream-format='(string)'byte-stream,profile= '(string)'high ! filesink location="/Users/sean/Desktop/gst_file/x264_enc.h264"

        //max-keyframe-interval=120 bitrate=400000 realtime=true


* 硬编码 （vtench264hw）cpu占用 6.7%
          
        realtime=true allow-frame-reordering=false
        
        设置 allow-frame-reordering = false  取消编码b帧

        gst-launch-1.0 avfvideosrc ! video/x-raw, format='(string)'NV12, width=1280, height=720,framerate=30/1 ! vtenc_h264_hw allow-frame-reordering=false realtime=true bitrate=2048 quality=1 ! video/x-h264,width= 1280, height=720,framerate=30/1 ! h264parse ! video/x-h264,stream-format='(string)'byte-stream ! capsfilter caps=video/x-h264,profile=high ! filesink location="/Users/sean/Desktop/gst_file/vt_enc.h264"


* 软解码（avdec_h264） (cpu 占用率 50% 左右)

        gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/gst_write720.h264" ! h264parse ! avdec_h264 ! videoconvert ! osxvideosink


* 硬解码（vtdec_hw） (cpu 占用率24%)

        gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/vt_enc.h264" ! h264parse ! video/x-h264,stream-format=avc ! vtdec_hw ! videoconvert ! osxvideosink
 
* 分离一个 MP4 的视频和音频并分别播放
 
 gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/huanbao.mp4" ! qtdemux name=demux  demux.audio_0 ! queue ! decodebin ! audioconvert ! audioresample ! autoaudiosink \
 demux.video_0 ! queue ! decodebin ! videoconvert ! videoscale ! osxvideosink


* 分离视频并播放
 
 gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/huanbao.mp4" ! qtdemux name=demux demux.video_0 ! queue ! decodebin ! videoconvert ! videoscale ! osxvideosink
 
* 混流两个测试画面
            
        gst-launch-1.0 -v videotestsrc ! video/x-raw,format=AYUV,framerate=\(fraction\)5/1,width=320,height=240 ! \
        videomixer name=mix background=1 sink_0::alpha=1 sink_1::alpha=1 ! \
        videoconvert ! glimagesink \
		 videotestsrc pattern=1 ! \
		 video/x-raw,format=AYUV,framerate=\(fraction\)10/1,width=100,height=100 ! \
		 videobox border-alpha=0 top=-70 bottom=-70 right=-220 ! mix.

* 混流两个视频文件（左右显示）

		gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/huanbao.mp4" ! qtdemux name=demux demux.video_0 ! queue ! decodebin ! videoscale ! videoconvert ! \
		 video/x-raw,format=AYUV,width=200,height=200 ! \
		 videobox border-alpha=0 top=-70 bottom=-70 right=-220 ! \
		 videomixer name=mix background=1 sink_0::alpha=1 sink_1::alpha=1 ! \
		 glimagesink \
		 filesrc location="/Users/sean/Desktop/gst_file/huanbao.mp4" ! qtdemux name=demux2 demux2.video_0 ! queue ! decodebin ! videoscale ! videoconvert ! \
		 video/x-raw,format=AYUV,width=200,height=200 ! \
		 videobox border-alpha=0 top=-70 bottom=-70 left=-220 ! mix.
 
 
 
* 多路视频合成显示(4路视频合成一个画面显示)
 
		 gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/huanbao.mp4" ! qtdemux name=demux demux.video_0 ! queue ! decodebin ! videoscale ! videoconvert ! \
		 video/x-raw,format=AYUV,width=200,height=200 ! \
		 videobox border-alpha=0 top=-180 bottom=-70 right=-220 ! \
		 videomixer name=mix background=1 sink_0::alpha=1 sink_1::alpha=1 sink_2::alpha=1 sink_3::alpha=1 ! \
		 glimagesink \
		 filesrc location="/Users/sean/Desktop/gst_file/huanbao.mp4" ! qtdemux name=demux2 demux2.video_0 ! queue ! decodebin ! videoscale ! videoconvert ! \
		 video/x-raw,format=AYUV,width=200,height=200 ! \
		 videobox border-alpha=0 top=-180 bottom=-100 left=-220 ! mix. \
		 filesrc location="/Users/sean/Desktop/gst_file/huanbao.mp4" ! qtdemux name=demux3 demux3.video_0 ! queue ! decodebin ! videoscale ! videoconvert ! \
		 video/x-raw,format=AYUV,width=200,height=200 ! \
		 videobox border-alpha=0 top=-20 bottom=0 left=-100 right=0 ! mix. \
		 filesrc location="/Users/sean/Desktop/gst_file/huanbao.mp4" ! qtdemux name=demux4 demux4.video_0 ! queue ! decodebin ! videoscale ! videoconvert ! \
		 video/x-raw,format=AYUV,width=200,height=200 ! \
		 videobox border-alpha=0 top=-360 bottom=-10 left=-100 right=0 ! mix.
 
 
 

 
 
 * 混流本地264视频文件（左右显示）
 
 // ! video/x-raw,format=AYUV,width=200,height=200 
 
		 gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/vt_enc.h264" ! h264parse name=parse ! video/x-h264,stream-format=avc ! vtdec_hw ! videorate ! videoscale ! video/x-raw,width=200,height=200 ! videoconvert ! video/x-raw,format=AYUV,width=200,height=200 ! videobox border-alpha=0 top=-180 bottom=-70 right=-220 ! compositor name=com background=1 sink_0::alpha=1 sink_1::alpha=1 sink_2::alpha=1 sink_3::alpha=1 ! glimagesink filesrc location="/Users/sean/Desktop/gst_file/x264_enc.h264" ! h264parse name=parse2 ! video/x-h264,stream-format=avc ! vtdec_hw ! videoscale ! video/x-raw,width=200,height=200 ! videoconvert ! video/x-raw,format=AYUV,width=200,height=200 ! videobox border-alpha=0 top=-180 bottom=-100 left=-220 ! com. filesrc location="/Users/sean/Desktop/gst_file/x264_enc.h264" ! h264parse name=parse3 ! video/x-h264,stream-format=avc ! vtdec_hw ! videoscale !  video/x-raw,width=200,height=200 ! videoconvert ! video/x-raw,format=AYUV,width=200,height=200 ! videobox border-alpha=0 top=-20 bottom=-300 left=-100 right=0 ! com. filesrc location="/Users/sean/Desktop/gst_file/x264_enc.h264" ! h264parse name=parse4 ! video/x-h264,stream-format=avc ! vtdec_hw ! videoscale ! video/x-raw,width=200,height=200 ! videoconvert ! video/x-raw,format=AYUV,width=200,height=200 ! videobox border-alpha=0 top=-360 bottom=0 left=-120 right=0 ! com. 
 
 
 
 //videorate max-rate=30 !
 ///
 GST_DEBUG=3 gst-launch-1.0 filesrc location="/Users/sean/Desktop/gst_file/vt_enc.h264" ! h264parse name=parse ! video/x-h264,stream-format=avc ! vtdec_hw ! videorate rate=1 !  videoscale ! video/x-raw,width=200,height=200 ! videoconvert ! video/x-raw,format=AYUV,width=200,height=200 ! videobox border-alpha=0 top=-180 bottom=-70 right=-220 ! glimagesink
///
 
 
 
 
##音频
    采集 -->回声抑制、降噪、自动增益-->编码（opus）-->发送； 