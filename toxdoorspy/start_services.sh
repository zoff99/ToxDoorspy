#! /bin/bash

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

cd "$_HOME_"

mkdir -p m/

export DOORSPYCAMDIR="$_HOME_"
export FFMPEGBINARY="/usr/bin/ffmpeg"
export MOTIONBINARY="motion"

#export FFMPEG_LOGFILE="$DOORSPYCAMDIR""/ffmpeg.log"
export FFMPEG_LOGFILE="/dev/null"
export MOTION_LOGFILE="$DOORSPYCAMDIR""/motioncapture.log"
export DOORSY_LOGFILE="$DOORSPYCAMDIR""/doorspytox.log"

# export QUIET=1

# export CAM_FPS="5"
export CAM_FPS="10"
export CAM_RES_W="640"
export CAM_RES_H="480"
export CAM_RES="${CAM_RES_W}x${CAM_RES_H}"


# export CAM_RES="640x480"
# export CAM_RES="1024x576"
# *too slow* # export CAM_RES="1920x1088"

if [ "$QUIET""x" == "1x" ]; then
	export FFMPEG_LOGFILE="/dev/null"
	export MOTION_LOGFILE="/dev/null"
	export DOORSY_LOGFILE="/dev/null"
fi

trap stop_services INT

function stop_services()
{
	echo "shutting down ..."

	echo "stoping motion capture ..."
	pkill -TERM motion
	echo "video device loopback ..."
	pkill -TERM ffmpeg

	sleep 5
	pkill -9 motion
	pkill -9 ffmpeg

	echo "shutdown ready!"

}


function stop_srvs_quick()
{
	echo "shutting down ..."

	echo "stoping motion capture ..."
	pkill -9 motion
	echo "video device loopback ..."
	pkill -9 ffmpeg

	echo "shutdown ready!"

}

cd "$DOORSPYCAMDIR"

# set default params for cam
v4l2-ctl -i /dev/video0 -C iso_sensitivity
v4l2-ctl -i /dev/video0 -c iso_sensitivity=4
v4l2-ctl -i /dev/video0 -C iso_sensitivity

v4l2-ctl -i /dev/video0 -C iso_sensitivity_auto
v4l2-ctl -i /dev/video0 -c iso_sensitivity_auto=0
v4l2-ctl -i /dev/video0 -C iso_sensitivity_auto

v4l2-ctl -i /dev/video0 -C image_stabilization
v4l2-ctl -i /dev/video0 -c image_stabilization=1
v4l2-ctl -i /dev/video0 -C image_stabilization

v4l2-ctl -i /dev/video0 -C auto_exposure
v4l2-ctl -i /dev/video0 -c auto_exposure=0
v4l2-ctl -i /dev/video0 -C auto_exposure

v4l2-ctl -i /dev/video0 -C exposure_time_absolute
v4l2-ctl -i /dev/video0 -c exposure_time_absolute=10000
v4l2-ctl -i /dev/video0 -C exposure_time_absolute

v4l2-ctl -i /dev/video0 -C scene_mode
v4l2-ctl -i /dev/video0 -c scene_mode=11
v4l2-ctl -i /dev/video0 -C scene_mode

v4l2-ctl -i /dev/video0 -C auto_exposure_bias
v4l2-ctl -i /dev/video0 -c auto_exposure_bias=24
v4l2-ctl -i /dev/video0 -C auto_exposure_bias



v4l2-ctl -i /dev/video0 -C compression_quality
v4l2-ctl -i /dev/video0 -c compression_quality=100
v4l2-ctl -i /dev/video0 -C compression_quality

v4l2-ctl -i /dev/video0 -C iso_sensitivity
v4l2-ctl -i /dev/video0 -c iso_sensitivity=4
v4l2-ctl -i /dev/video0 -C iso_sensitivity



# frame rate
v4l2-ctl -i /dev/video0 -p "$CAM_FPS"

# v4l2-ctl -i /dev/video0 --set-fmt-video=width=1920,height=1088,pixelformat=4
v4l2-ctl -i /dev/video0 --set-fmt-video=width="$CAM_RES_W",height="$CAM_RES_H"
v4l2-ctl -i /dev/video1 --set-fmt-video=width="$CAM_RES_W",height="$CAM_RES_H"

v4l2-ctl -c video_bitrate=25000000,video_bitrate_mode=0,compression_quality=100

v4l2-ctl -i /dev/video0 -c brightness=50
v4l2-ctl -i /dev/video0 -c iso_sensitivity_auto=0
v4l2-ctl -i /dev/video0 -c white_balance_auto_preset=1
v4l2-ctl -i /dev/video0 -c color_effects=0

# -- set Black & white mode ---
# v4l2-ctl -i /dev/video0 -c color_effects=1
# -- set Black & white mode ---

echo "starting motion capture ..."
nohup "$MOTIONBINARY" -c ./motion.conf -d 6 > "$MOTION_LOGFILE" 2>&1 &

echo "starting doorspy-tox ..."
./toxdoorspy --videodevice /dev/video1 > "$DOORSY_LOGFILE" 2>&1

stop_services

