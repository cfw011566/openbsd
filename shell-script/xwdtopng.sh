#!/bin/sh
# need "Netpbm"

if [ $# -lt 1 ]; then
	echo "usage: $0 file"
	echo "convert file.xwd to file.png"
	exit 1
fi

for i in $@
do
	xwdtopnm < $i.xwd | pnmtopng > $i.png
done
exit 0
