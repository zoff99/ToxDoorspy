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

echo "cd $DOORSPYCAMDIR"
cd "$DOORSPYCAMDIR"

echo "starting motion capture ..."
nohup "$MOTIONBINARY" -c ./motion.conf -d 8 > "$MOTION_LOGFILE" 2>&1 &

sleep 5

echo "starting doorspy-tox ..."
./toxdoorspy --videodevice /dev/video1 > "$DOORSY_LOGFILE" 2>&1

stop_services

