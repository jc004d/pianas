#!/usr/bin/env bash
touch port.txt
old_port=`cat port.txt`
./port_forwarding.sh --output=port.txt
port=`cat port.txt`

if [ "$old_port" != "$port" ]; then
	/usr/local/etc/rc.d/transmission stop
	echo "setting transmission port forward to $port"
	sed -i .orig 's/.*"peer-port".*/"peer-port": '"$port"',/g' /usr/local/etc/transmission/home/settings.json
	/usr/local/etc/rc.d/transmission start
else
	echo "no port change"
fi
