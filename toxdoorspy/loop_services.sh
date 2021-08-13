#! /bin/bash

_HOME2_=$(dirname $0)
export _HOME2_
_HOME_=$(cd $_HOME2_;pwd)
export _HOME_

cd $_HOME_

echo "running doorspy forever ..."

while [ true ]; do
	./start_services.sh
	echo "doorspy ** restarting ** ..."
	sleep 3
done

