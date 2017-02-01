#! /bin/bash

. ./set_os_dir.sh
exec "$_OS_DIR_"/$(basename "$0")
