#!/bin/sh
PROGNAME=`/usr/bin/basename $0`

case $# in
1) loc=mis; file=$1;;
2) loc=$1; file=$2;;
*) echo "usage: $PROGNAME [mis | sw | hw ] file.ps"; exit 1 ;;
esac

if [ ! -f $file ]; then
	echo $file not exist
	exit 1
fi

#ps=`echo $file | grep 'ps$'`
ps=`head -1 $file | grep '^%!PS'`

if [ X"$ps" = X ]; then
	echo $file is not a ps file
	exit 1
fi

case $loc in
sw) server='//telewin2/1300_HP2100'; dev=pxlmono ; res=600 ;;
hw) server='//telewin2/1320_HP4000'; dev=pxlmono ; res=1200 ;;
mis) server='//telewin2/1210_HPLJP3005'; dev=pxlmono ; res=600 ;;
copy) server='//telewin2/KONICAMI'; dev=pxlmono ; res=1200 ;;
*) echo "usage: $0 [sw | hw | mis] file.ps"; exit 1 ;;
esac

echo print $file to $loc

psnup -2 -pA4 $file 2> /dev/null | \
gs -dSAFER -dBATCH -dNOPAUSE -q \
   -sDEVICE=$dev -r$res -sPAPERSIZE=a4 -sOutputFile=- - 2> /dev/null | \
smbclient $server -c "print -"

#gs -dSAFER -dBATCH -dNOPAUSE -q \
#   -sDEVICE=$dev -r$res -sPAPERSIZE=a4 -sOutputFile=- - | \
