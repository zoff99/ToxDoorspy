#! /bin/bash

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_


echo $_HOME_
cd $_HOME_ || exit 1

export _INST_=$_HOME_/inst/

git clone https://github.com/zoff99/ToxDoorspy
git clone https://github.com/zoff99/c-toxcore

mkdir -p $_INST_

cd c-toxcore/ || exit 1
./autogen.sh || exit 1

export CFLAGS=" -D_GNU_SOURCE -g -O2 -fPIC -fstack-protector-all --param=ssp-buffer-size=1 "
export CXXFLAGS="-fPIC -fstack-protector-all --param=ssp-buffer-size=1 "
export CFLAGS=" $CFLAGS -Werror=div-by-zero "
export LDFLAGS=" -O2 -fPIC "

./configure \
  --prefix="$_HOME_"/inst/ \
  --disable-soname-versions --disable-testing || exit 1

make -j$(nproc) || exit 1
make install || exit 1

cd $_HOME_/ToxDoorspy/toxdoorspy/ || exit 1

export CFLAGS=" -fPIC -std=gnu99 -I$_INST_/include/ -L$_INST_/lib -O2 -g -fstack-protector-all --param=ssp-buffer-size=1 "

gcc $CFLAGS \
toxdoorspy.c \
$_INST_/lib/libtoxcore.a \
$_INST_/lib/libtoxav.a \
-lopus \
-lvpx \
-lx264 \
-lavcodec \
-lavutil \
-lsodium \
-lm \
-ldl \
-lv4lconvert \
-lpthread \
-o toxdoorspy


