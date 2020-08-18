#!/bin/bash

mkdir /root/ap

(
interface=wlan1
dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h
dhcp-option=3,192.168.1.1
dhcp-option=6,192.168.1.1
server=8.8.8.8
log-queries
log-dhcp
listen-address=127.0.0.1
)>>/root/ap/dnsmasq.conf

(
interface=wlan1
driver=nl80211
ssid=sinister-chalister
hw_mode=g
channel=6
macaddr_acl=0
ignore_broadcast_ssid=0
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=TKIP
wpa_passphrase=deviant_pk
)>>/root/ap/hostapd.conf

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