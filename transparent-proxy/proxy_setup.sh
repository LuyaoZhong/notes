#!/bin/bash
set -x
source environment.inc

# install and config redsocks
if [ x$DISTRO == 'xUbuntu' ]; then
	sudo apt install -y redsocks autossh
else
	echo "not supported os"
        exit
fi

sudo -E tee /etc/redsocks.conf >/dev/null << EOF
base {
        log_debug = on;
        log_info = on;
        log = "file:/var/log/redsocks.log";
        daemon = on;
        redirector = iptables;
}
redsocks {
        local_ip = 127.0.0.1;
        local_port = 7777;
        ip = $PROXY_IP;
        port = $PROXY_PORT;
        type = $PROXY_TYPE;
}
redudp {
        local_ip = 127.0.0.1;
        local_port = 8888;
        ip = $PROXY_IP;
        port = $PROXY_PORT;
        udp_timeout = 30;
        udp_timeout_stream = 180;
}
dnstc {
        local_ip = 127.0.0.1;
        local_port = 5300;
}
EOF

sudo tee /bin/proxy.sh >/dev/null << EOF
iptables -t nat -N REDSOCKS || true
iptables -t nat -F REDSOCKS
iptables -t nat -D OUTPUT -p tcp -j REDSOCKS
iptables -t nat -D PREROUTING -p tcp -j REDSOCKS
iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN
iptables -t nat -A REDSOCKS -p tcp -j DNAT --to-destination 127.0.0.1:7777
iptables -t nat -A REDSOCKS -p udp -j DNAT --to-destination 127.0.0.1:8888
iptables -t nat -A OUTPUT -p tcp -j REDSOCKS
iptables -t nat -A PREROUTING -p tcp -j REDSOCKS
EOF

sudo chmod +x /bin/proxy.sh

sudo /bin/proxy.sh

# sudo service redsocks restart
sudo systemctl restart redsocks

# settings for docker
sudo sysctl -w net.ipv4.conf.default.route_localnet=1
sudo sysctl -w net.ipv4.conf.all.route_localnet=1

grep "route_localnet" /etc/sysctl.conf
if [ $? -ne 0 ]; then
    sudo tee -a /etc/sysctl.conf >/dev/null << EOF
net.ipv4.conf.all.route_localnet = 1
net.ipv4.conf.default.route_localnet = 1
EOF
fi

if [ $PROXY_IP == "127.0.0.1" ]; then
    # ./tunnel.sh set up ssh tunnel via autossh
fi
exit 0
