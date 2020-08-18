#!/bin/bash

nmcli dev status
cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.old
(
	echo "[keyfile]"
	echo "unmanaged-devices=interface-name:wlan1"
)>>/etc/NetworkManager/NetworkManager.conf

ifconfig wlan1 down
iwconfig wlan1 mode monitor
ifconfig wlan1 up
hostapd hostapd.conf
ifconfig wlan1 up 192.168.1.1 netmask 255.255.255.0
route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1
dnsmasq -C dnsmasq.conf -d
iptables --table nat --append POSTROUTING --out-interface wlan0 -j MASQUERADE
iptables --append FORWARD --in-interface wlan1 -j ACCEPT
echo 1 > /proc/sys/net/ipv4/ip_forward