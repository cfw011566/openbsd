#!/bin/sh
PROGNAME=`/usr/bin/basename $0`
MIS="//telewin2/1210_HPLJP3005"
COPY="//telewin2/KONICAMI"


print_usage() {
	echo "usage: $PROGRAM [-h] [-l location] [-r resolution] file"
	echo "location: mis or copy"
	echo "resolution: default 600"
}

if [ $# -lt 1 ]; then
	print_usage
	exit 1
fi

res=600
server=$MIS
dev=pxlmono
loc=mis

while test -n "$1"; do
	case "$1" in
	-h)
		print_usage
		exit 0
		;;
	-l)
		loc=$2
		;;
	-r)
		res=$2
		;;
	*)
		file=$1
		;;
	esac
	shift
done

if [ -n "$loc" ]; then
	case $loc in
	mis)
		server=$MIS
		;;
	copy)
		server=$COPY
		;;
	*)
		print_usage
		exit 1
		;;
	esac
fi

#echo $server
#echo $res
#echo $file
#exit 0

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

echo print $file to $loc
# resize the page
# pstops '1:0@1.3(-3cm,-4cm)' ws-1.ps outfile.ps

gs -dSAFER -dBATCH -dNOPAUSE -q \
   -sDEVICE=$dev -r$res -sPAPERSIZE=a4 -sOutputFile=- $file 2> /dev/null | \
smbclient $server -c "print -"
