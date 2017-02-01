#! /bin/bash

_dir=$(dirname "${0}")
. "$_dir"/set_os_dir.sh
"$_dir"/"$_OS_DIR_"/$(basename "$0")
