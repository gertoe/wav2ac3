#!/bin/bash
# Adapted from https://forum.videohelp.com/threads/335904-How-to-Convert-2-channel-stereo-wave-into-DD5-1-AC3-448-AC-640
#
# usage sh wav2ac3.sh stereoInput.wav

#resample to 48kHz and lower volume to avaid clipping
sox -S -V -c 2 $1 -r 48k stereoInput.wav gain -h

#front = stereo.soxfilter("filter 20-20000")
sox -S -V -c 2 stereoInput.wav front.wav sinc 20-20000
sox -S -V front.wav frontL.wav remix 01
sox -S -V front.wav frontR.wav remix 02

#fl = mixaudio(front.GetLeftChannel(),front.GetRightChan nel(),0.794,-0.794)
sox -S -V -c 2 front.wav front_left.wav remix -m 1v0.794,2v-0.794

#fr = mixaudio(front.GetRightChannel(),front.GetLeftChan nel(),0.794,-0.794)
sox -S -V -c 2 front.wav front_right.wav remix -m 2v0.794,1v-0.794

#rear = stereo.soxfilter("filter 100-7000")
sox -S -V -c 2 stereoInput.wav rear.wav sinc 100-7000

#sl = mixaudio(rear.GetLeftChannel(),rear.GetRightChanne l(),0.562,-0.562)
#sl = DelayAudio(sl,0.02)
sox -S -V -c 2 rear.wav rear_left.wav remix -m 1v0.562,2v-0.562 delay 0.02

#sr = mixaudio(rear.GetRightChannel(),rear.GetLeftChanne l(),0.562,-0.562)
#sr = DelayAudio(sr,0.02)
sox -S -V -c 2 rear.wav rear_right.wav remix -m 1v0.562,2v-0.562 delay 0.02

#cc = mixaudio(mixaudio(front.GetLeftChannel(),fl,1,-1),mixaudio(front.GetRightChannel(),fr,1,-1),0.224,0.224)
# = mixaudio(cc_l, cc_r, 0.224,0.224)
#cc_l(1) = mixaudio(front.GetLeftChannel(),fl,1,-1)
#cc_r(1) = mixaudio(front.GetRightChannel(),fr,1,-1)
sox -S -V -M frontL.wav front_left.wav centerL.wav remix -m 1v0.224,2v-0.224
sox -S -V -M frontR.wav front_right.wav centerR.wav remix -m 1v0.224,2v-0.224
sox -S -V -m centerL.wav centerR.wav center.wav

#lfe = ConvertToMono(stereo).SoxFilter("lowpass 120","vol -0.596")
sox -S -V -v -0.596 stereoInput.wav -c 1 lfe.wav lowpass 120

ffmpeg -i front_left.wav -i front_right.wav -i center.wav -i lfe.wav -i rear_left.wav -i rear_right.wav -filter_complex "[0:a][1:a][2:a][3:a][4:a][5:a]amerge=inputs=6[aout]" -map "[aout]" audio.wav

ffmpeg -i audio.wav -acodec ac3 audio.ac3 
