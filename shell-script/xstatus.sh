#!/bin/sh

netbytes="/tmp/trunk0-bytes"

rate()
{
	if [ `dc -e "$1 10000000 ( p"` -eq 1 ]; then
		echo -n "<fc=red>`dc -e "1 k $1 1000000 / p"`M</fc>"
	elif [ `dc -e "$1 1000000 ( p"` -eq 1 ]; then
		echo -n "<fc=magenta>`dc -e "2 k $1 1000000 / p"`M</fc>"
	elif [ `dc -e "$1 100000 ( p"` -eq 1 ]; then
		echo -n "<fc=orange>`dc -e "0 k $1 1000 / p"`K</fc>"
	elif [ `dc -e "$1 10000 ( p"` -eq 1 ]; then
		echo -n "<fc=green>`dc -e "1 k $1 1000 / p"`K</fc>"
	elif [ `dc -e "$1 1000 ( p"` -eq 1 ]; then
		echo -n "<fc=green>`dc -e "2 k $1 1000 / p"`K</fc>"
	else
		echo -n "<fc=cyan>$1</fc>"
#		echo -n "<fc=cyan>`printf "%-4d" $1`</fc>"
	fi
}

netusage()
{
	set `netstat -n -I trunk0 -b | tail -1 | awk '{print $5 " " $6}'`
	newin=$1
	newout=$2
	cur=`date +%s`
	if [ -e $netbytes ]; then
		set `cat $netbytes`
		irate=$((($newin-$2)/($cur-$1)))
		orate=$((($newout-$3)/($cur-$1)))
		echo -n "I:$(rate $irate) O:$(rate $orate)"
	else
		echo -n "I:- O:-"
	fi
	echo "$cur $newin $newout" > $netbytes
}

network()
{
	set `/sbin/ifconfig iwm0 | grep nwid | awk '{print $3 " " $8}' | sed -e 's/%//'`
	ssid=$1 
	db=$2
	color=green
	if [ $db -ge 70 ]; then
		color=green
	elif [ $db -ge 50 ]; then
		color=orange
	elif [ $db -ge 20 ]; then
		color=magenta
	else
		color=red
	fi
	netif=`/sbin/ifconfig trunk0 | grep trunkport | grep active | awk '{print $2}'`
	case $netif in
	iwm*)
		echo -n "<fc=white>$ssid</fc> <fc=$color>$db%</fc>"
		;;
	em*)
		echo -n "<fc=cyan>`/sbin/ifconfig em0 | grep media | sed 's/.*(//' | awk '{print $1}'`</fc>"
		;;
	*)
		echo -n "<fc=white,red>NO network</fc>"
		;;
	esac
}

volcolor()
{
	case $1 in
	[0-9]|1[0-9])
		echo -n "blue" ;;
	[2-3][0-9])
		echo -n "cyan" ;;
	[4-5][0-9])
		echo -n "green" ;;
	[6-7][0-9])
		echo -n "orange" ;;
	[8-9][0-9])
		echo -n "magenta" ;;
	*)
		echo -n "white,red" ;;
	esac
}

vol()
{
	vol=`mixerctl -n outputs.master | sed 's/.*,//'`
	mute=`mixerctl -n outputs.master.mute`
	vol=$(($vol*100/255))
	if [ $mute = "on" ]; then
		echo -n "<fc=white,red>Vol:$vol%</fc>"
	else
#		echo -n "<fc=white>Vol:$(($vol*100/255))</fc>%"
		echo -n "<fc=white>Vol:</fc><fc=$(volcolor $vol)>$vol</fc>%"
	fi

}

bat0()
{
	raw=`sysctl -n hw.sensors.acpibat0.raw0 | sed 's/ .*//'`
	sysctl hw.sensors.acpibat0 | grep amphour > /dev/null
	if [ $? -eq 0 ]; then
		# cuurent, amphour
		now=`sysctl -n hw.sensors.acpibat0.current0 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		full=`sysctl -n hw.sensors.acpibat0.amphour0 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		warning=`sysctl -n hw.sensors.acpibat0.amphour1 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		low=`sysctl -n hw.sensors.acpibat0.amphour2 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		remaining=`sysctl -n hw.sensors.acpibat0.amphour3 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
	else
		# power, watthour
		now=`sysctl -n hw.sensors.acpibat0.power0 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		full=`sysctl -n hw.sensors.acpibat0.watthour0 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		warning=`sysctl -n hw.sensors.acpibat0.watthour1 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		low=`sysctl -n hw.sensors.acpibat0.watthour2 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		remaining=`sysctl -n hw.sensors.acpibat0.watthour3 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
	fi

	if [ "X$now" == "X" ]; then
		now="0"
	fi
	echo -n "$raw $now $full $warning $low $remaining"
}

bat1()
{
	raw=`sysctl -n hw.sensors.acpibat1.raw0 | sed 's/ .*//'`
	sysctl hw.sensors.acpibat1 | grep amphour > /dev/null
	if [ $? -eq 0 ]; then
		# cuurent, amphour
		now=`sysctl -n hw.sensors.acpibat1.current0 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		full=`sysctl -n hw.sensors.acpibat1.amphour0 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		warning=`sysctl -n hw.sensors.acpibat1.amphour1 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		low=`sysctl -n hw.sensors.acpibat1.amphour2 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		remaining=`sysctl -n hw.sensors.acpibat1.amphour3 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
	else
		# power, watthour
		now=`sysctl -n hw.sensors.acpibat1.power0 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		full=`sysctl -n hw.sensors.acpibat1.watthour0 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		warning=`sysctl -n hw.sensors.acpibat1.watthour1 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		low=`sysctl -n hw.sensors.acpibat1.watthour2 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
		remaining=`sysctl -n hw.sensors.acpibat1.watthour3 | sed 's/ .*//' | sed 's/\.//' | sed 's/^0*//'`
	fi

	if [ "X$now" == "X" ]; then
		now="0"
	fi
	echo -n "$raw $now $full $warning $low $remaining"
}

power()
{
	# status ?? 0 = battery idle, 1 = battery discharging, 2 = battery charging

	sysctl hw.sensors.acpibat1.raw0 | grep idle > /dev/null
	if [ $? -eq 0 ]; then
		set `bat0`
	else
		set `bat1`
	fi

	raw=$1
	now=$2
	full=$3
	warning=$4
	low=$5
	remaining=$6

	if [ $remaining -lt $low ]; then
		color="red"
	elif [ $remaining -lt $warning ]; then
		color="orange"
	else
		color="green"
	fi

	percent=$(($remaining*100/$full))

	case $raw in
	0)
		echo -n "<fc=yellow>A/C $percent%</fc>"
		;;
	1)
		if [ -n "$now" ]; then
			minute=$(($remaining*60/$now))
		else
			minute="---"
		fi
		echo -n "<fc=black,$color>${minute}min $percent%</fc>"
#		if [ $color = "red" ]; then
#			echo -n "<fc=black,$color>${minute}min $percent</fc>%"
#		else
#			echo -n "<fc=black,$color>$minute</fc>min <fc=$color>$percent</fc>%"
#		fi
		;;
	2)
		echo -n "<fc=$color>A/C ${percent}%</fc>"
#		color="magenta"
#		if [ -n "$now" ]; then
#			minute=$((($full-$remaining)*60/$now))
#			echo -n "<fc=black,$color>A/C ${minute}min</fc>"
#		else
#			echo -n "<fc=black,$color>A/C ${percent}%</fc>"
#		fi
		;;
	*)
		echo -n "<fc=red> Error </fc>"
	esac
}

loadcolor()
{
	case $1 in
	0.[0-7]*)
		echo -n "cyan" ;; #00ffff cyan
	0.[8-9]*|1.[0-5]*)
		echo -n "green" ;;
	1.[6-9]*|2.[0-4]*)
		echo -n "orange" ;; #ff00ff magenta
	2.[5-9]*|3.*)
		echo -n "magenta" ;; #ff00ff magenta
	*)
		echo -n "white,red" ;;
	esac
}

load()
{
	set `/sbin/sysctl -n vm.loadavg`
	echo -n "<fc=$(loadcolor $1)>$1</fc>"
	echo -n " "
	echo -n "<fc=$(loadcolor $2)>$2</fc>"
	echo -n " "
	echo -n "<fc=$(loadcolor $3)>$3</fc>"
}

tempcolor()
{
	case $1 in
	[1-3][0-9])
		echo -n "blue" ;;
	4[0-9])
		echo -n "cyan" ;;
	5[0-9])
		echo -n "green" ;;
	6[0-9])
		echo -n "orange" ;;
	7[0-5])
		echo -n "magenta" ;;
	*)
		echo -n "white,red" ;;
	esac
}

temp()
{
	temp=`/sbin/sysctl -n hw.sensors.acpitz0.temp0 | sed 's/\..*//'`
	echo -n "<fc=$(tempcolor $temp)>$temp</fc>C "

	fan=`/sbin/sysctl -n hw.sensors.acpithinkpad0.fan0 | sed 's/ .*//'`
	case $fan in
	1*)
		echo -n "<fc=blue>" ;;
	2*)
		echo -n "<fc=cyan>" ;;
	3[0-4]*)
		echo -n "<fc=green>" ;;
	3[5-9]*)
		echo -n "<fc=orange>" ;;
	4*)
		echo -n "<fc=magenta>" ;;
	*)
		echo -n "<fc=white,red>" ;;
	esac
	echo -n "${fan}</fc>RPM"

#	temp=`/sbin/sysctl -n hw.sensors.itherm0.temp10 | sed 's/\..*//'`
#	echo -n "<fc=$(tempcolor $temp)>$temp</fc>C"
}

$1
