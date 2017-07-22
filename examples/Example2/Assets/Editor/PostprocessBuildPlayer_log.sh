#!/bin/bash
#
# a simple script to troubleshoot the PostProcessingBuildPlayer arguments
#
# change this value to non 0 to enable logging
debug=1

install_path=$1
dir=`dirname $install_path`
file=$dir/PostprocessBuildPlayer.log

if [ $debug -eq 0 ]; then
	exit 0
fi

echo "$0"
if [ -f $file ]; then
	rm  $file
fi
date >> $file
echo 0 $0 >> $file
echo 1 $1 >> $file
echo 2 $2 >> $file
echo 3 $3 >> $file
echo 4 $4 >> $file
echo 5 $5 >> $file
echo 6 $6 >> $file
echo 7 $7 >> $file
echo 8 $8 >> $file
echo 9 $9 >> $file
echo all \"$1\" \"$2\" \"$3\" \"$4\" \"$5\" \"$6\" \"$7\" \"$8\" \"$9\" >> $file