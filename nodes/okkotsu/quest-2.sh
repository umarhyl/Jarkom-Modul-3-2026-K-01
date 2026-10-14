#!/bin/sh

killall udhcpc 2>/dev/null
udhcpc -i eth0 -n -q
ip -br addr show eth0