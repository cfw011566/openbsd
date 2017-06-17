#!/bin/sh

file="/tmp/weather.html"
tempfile="/tmp/temp.txt"
rainfile="/tmp/rain.txt"
#lists="Tamsui Taipei Taichung Tainan Kaohsiung Hualien Taitung Yushan"
lists="Tamshui Taipei Tainan"

tempcolor()
{
	case $1 in
	-*)
		echo -n "white" ;;
	[0-9].*)
		echo -n "purple" ;;
	1[0-7].*)
		echo -n "cyan" ;;
	1[8-9].*|2[0-5].*)
		echo -n "green" ;;
	2[6-9].*|3[0-4].*)
		echo -n "magenta" ;;
	*)
		echo -n "red" ;;
	esac
}

humcolor()
{
	case $1 in
	[0-9]|[0-1][0-9])
		echo -n "red" ;;
	[2-4][0-9])
		echo -n "magenta" ;;
	[5-7][0-9])
		echo -n "green" ;;
	8[0-9]|9[0-4])
		echo -n "cyan" ;;
	9[5-9]|100)
		echo -n "purple" ;;
	*)
		echo -n "red" ;;
	esac
}

epoc=`date +%s`
sec=0
if [ -e ${file} ]; then
	export `stat -s ${file}`
	sec=$((${epoc} - ${st_ctime}))
fi

if [ ! -e $file -o $sec -gt 900 ]; then
	curl -s -o $file http://cwb.gov.tw/V7e/observe/real/ALL.htm
	if [ $? -ne 0 ]; then
		exit 0
	fi

	echo -n "" > $tempfile
	echo -n "" > $rainfile
	for i in $lists
	do
		msg=`cat $file | grep $i | head -1 | tr -s "\357\274\215" "-" | sed 's/.*\/th>//' | sed 's/<td colspan=10>//' | sed "s/<\/td><td style=.*20px'>/:/" | sed 's/<\/td><td>/:/g' | sed 's/.*temp1">//' | sed 's/<\/td>.*temp2">/:/' | sed 's/<font color=red>\*<\/font>//g' | sed 's/<font color=//' | sed 's/<\/font>//' | sed 's/<\/td>.*//' | sed 's/>/:/'`
		temp=`echo $msg | awk -F ':' '{print $1}'`
		cout="<fc=white>$i</fc> "
		if [ ${temp}"X" = "X" ]; then
			cout="${cout}<fc=red>*</fc> "
		else
			if [ ${temp} = "-" ]; then
				cout="${cout}<fc=white>-</fc> "
			else
				cout="${cout}<fc=$(tempcolor ${temp})>${temp}</fc>C "
			fi
		fi
		echo -n "$cout" >> $tempfile

		raincolor=`echo $msg | awk -F ':' '{print $10}'`
		if [ $raincolor = "blue" ]; then
			raincolor="cyan"
		elif [ $raincolor = "black" -o $raincolor = " - " ]; then
			raincolor="white"
		fi
		rain=`echo $msg | awk -F ':' '{print $11}'`

		cout="<fc=white>$i</fc> "
		if [ ${rain}"X" = "X" ]; then
			cout="${cout}<fc=red>*</fc> "
		elif [ ${rain} = "TRACE" -o ${rain} = "-" ]; then
			cout="${cout}<fc=$raincolor>${rain}</fc> "
		else
			cout="${cout}<fc=$raincolor>${rain}</fc>mm "
		fi
		echo -n "$cout" >> $rainfile
	done
fi

set `echo $lists`
count=$(($# + 1))
shift $(($epoc / 10 % $count))
city=$1

if [ -z $city ]; then
#	cat $tempfile
	cat $rainfile
	exit 0
fi

if [ -e /tmp/$city -a /tmp/$city -nt $file ]; then
	cat /tmp/$city
	exit 0
fi

#msg=`cat $file | grep $city | sed 's/<\/td><td>/:/g' | sed 's/.*temp1">//' | sed 's/<\/td>.*temp2">/:/' | sed 's/<font color=red>\*<\/font>//g' | sed 's/<\/td.*color=/:/' | sed 's/<\/font.*//' | sed 's/>/:/'`
#msg=`cat $file | grep $city | sed "s/<\/td><td style=.*20px'>/:/" | sed 's/<\/td><td>/:/g' | sed 's/.*temp1">//' | sed 's/<\/td>.*temp2">/:/' | sed 's/<font color=red>\*<\/font>//g' | sed 's/<font color=//' | sed 's/<\/font>//' | sed 's/<\/td>.*//' | sed 's/>/:/'`
#msg=`cat $file | grep $city | sed 's/.*\/th>//' | sed 's/<td colspan=10>//' | sed "s/<\/td><td style=.*20px'>/:/" | sed 's/<\/td><td>/:/g' | sed 's/.*temp1">//' | sed 's/<\/td>.*temp2">/:/' | sed 's/<font color=red>\*<\/font>//g' | sed 's/<font color=//' | sed 's/<\/font>//' | sed 's/<\/td>.*//' | sed 's/>/:/'`
msg=`cat $file | grep $city | head -1 | tr -s "\357\274\215" "-" | sed 's/.*\/th>//' | sed 's/<td colspan=10>//' | sed "s/<\/td><td style=.*20px'>/:/" | sed 's/<\/td><td>/:/g' | sed 's/.*temp1">//' | sed 's/<\/td>.*temp2">/:/' | sed 's/<font color=red>\*<\/font>//g' | sed 's/<font color=//' | sed 's/<\/font>//' | sed 's/<\/td>.*//' | sed 's/>/:/'`
temp=`echo $msg | awk -F ':' '{print $1}'`
condition=`echo $msg | awk -F ':' '{print $3}'`
direction=`echo $msg | awk -F ':' '{print $4}'`
hum=`echo $msg | awk -F ':' '{print $8}'`
raincolor=`echo $msg | awk -F ':' '{print $10}'`
if [ $raincolor = "blue" ]; then
	raincolor="cyan"
elif [ $raincolor = "black" -o $raincolor = " - " ]; then
	raincolor="white"
fi
rain=`echo $msg | awk -F ':' '{print $11}'`

cout="<fc=white>$city</fc> "
tout="$city"
if [ ${temp}"X" = "X" ]; then
	cout="${cout}<fc=red>*</fc> "
	tout="${tout}* "
else
	if [ ${temp} = "-" ]; then
		cout="${cout}<fc=white>-</fc> "
		tout="${tout}- "
	else
		cout="${cout}<fc=$(tempcolor ${temp})>${temp}</fc>C "
		tout="${tout}$(tempcolor ${temp})C "
	fi
fi

if [ -z "${direction}" ]; then
	cout="${cout}<fc=red>*</fc> "
	tout="${tout}* "
else
	cout="${cout}<fc=yellow>$direction</fc> "
	tout="${tout}$direction "
fi
if [ ${hum}"X" = "X" ]; then
	cout="${cout}<fc=red>*</fc> "
	tout="${tout}* "
elif [ ${hum} = "-" ]; then
	cout="${cout}<fc=white>-</fc> "
	tout="${tout}- "
else
	cout="${cout}<fc=$(humcolor ${hum})>${hum}</fc>% "
	tout="${tout}$(humcolor ${hum})${hum}% "
fi
if [ ${rain}"X" = "X" ]; then
	cout="${cout}<fc=red>*</fc> "
	tout="${tout}* "
elif [ ${rain} = "TRACE" -o ${rain} = "-" ]; then
	cout="${cout}<fc=$raincolor>${rain}</fc> "
	tout="${tout}${rain} "
else
	cout="${cout}<fc=$raincolor>${rain}</fc>mm "
	tout="${tout}${rain}mm "
fi
cout="${cout}<fc=yellow>${condition}</fc>"
tout="${tout}${condition}"

xres=`xrandr | grep connected | grep '+0+0' | sed 's/+0+0.*//' | sed 's/.*connected //' | sed 's/x.*//'`
nout=`echo ${tout} | wc -c`
if [ ${xres} -le 1280 -a ${nout} -ge 40 ]; then
	echo ${tout} | grep -q 'mm'
	if [ $? -eq 0 ]; then
		cout=`echo ${cout} | sed 's/mm.*/mm/'`
	else
		cout=`echo ${cout} | sed 's/TRACE<\/fc>.*/TRACE<\/fc>/'`
	fi
fi

echo $cout > /tmp/$city
echo -n $cout

exit 0

