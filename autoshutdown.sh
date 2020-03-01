#!/bin/sh

set1="" # These hosts have to ping -> plugin on the ups
set_1="${set_1} 10.0.0.3" # Routeur
set_1="${set_1} 10.0.0.10" # ESXi G8
set_1="${set_1} 10.0.0.10" # iLO G8
set_1="${set_1} 10.0.0.11" # ESXi G8
set_1="${set_1} 10.0.0.11" # iLO G6

set2=""  # These hosts have to not ping in case of power cut off -> not plugged on the ups
set_2="${set_2} 192.168.0.254" # Freebox
set_2="${set_2} 10.0.4.25" # Ubuntu PC

set3="" # These hosts have to ping with internet access working
set_3="${set_3} 8.8.8.8" # Google
set_3="${set_3} 1.1.1.1" # Cloudflare
set_3="${set_3} 9.9.9.9" # Quad9


# Rules
# If set3 ping -> internet access -> all good
# if set2 -> home infra reachable -> only internet fail
# if not set3 and not set2 and set1 -> only ups device rechable -> NEED TO SHUTDOWN
# if not set3 and not set2 and not set3 -> Could be a network error -> do nothing (or shutdown depending of what you want)

d=`date "+%Y-%m-%d-%H-%M-%S"`
echo $d

test_set(){
	set=$1
	ping_ok=0
	ping_fail=0
	for ip in ${set}
	do
		printf '~ Ping %-15s : ' "$ip"
		ping -c 1 $ip 1>/dev/null 2>/dev/null
		if [ "$?" -eq 0 ]
		then
			# ping success
			echo "ok"
			ping_ok=$((ping_ok+1))
		else
			# ping fails
			echo "fail"
			ping_fail=$((ping_fail+1))
		fi
	done
	if [ "$ping_ok" -gt "$ping_fail" ]
	then
		echo "~~> OK"
		return 1
	else
		echo "~~> FAIL"
		return 0
	fi
}

shutdown_esxi(){
	echo esxcli system shutdown poweroff --reason "NoPower need to shutdown"
}

echo ""
echo "Test Internet"
test_set "$set_3"
res_set_3=$?
echo "Result Internet $res_set_3"
echo ""
echo "Test Infra"
test_set "$set_2"
res_set_2=$?
echo "Result Infra $res_set_2"
echo ""
echo "Test UPS"
test_set "$set_1"
res_set_1=$?
echo "Result UPS devices $res_set_1"
echo ""

# If internet ping -> all good
if [ "$res_set_3" -eq "1" ]
then
	echo "RESULT $d: ALL GOOD"
	exit 0
fi

# if out of ups device available -> just no internet (problem with the router for exemple)
if [ "$res_set_2" -eq "1" ]
then
	echo "RESULT $d: ALL GOOD (no internet)"
	exit 0
fi

# if no ping to over devices on the ups -> Could be a network issue
if [ "$res_set_1" -eq "0" ]
then
	echo "RESULT $d: Nothing answer -> Could be a network issue"
	exit 0
fi

# only ups devices ping -> NO POWER -> need to shutdown
if [ "$res_set_1" -eq "1" ]
then
	echo "RESULT $d: NO POWER -> SHUTDOWN"
	shutdown_esxi
	# This exit is useless :)
	exit 0
fi
