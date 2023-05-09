# Variables

export DISTRO=$(lsb_release -i |awk '{print $3}')

# Available proxies
# xx.xx.xx.xx - proxy
# 127.0.0.1 - tunnel, need to set up ssh tunnel from local ip:port to remote ip:port via jump machine
#export PROXY_IP=
#export PROXY_PORT=
export PROXY_TYPE=socks5
export PROXY_IP=127.0.0.1
export PROXY_PORT=1080

