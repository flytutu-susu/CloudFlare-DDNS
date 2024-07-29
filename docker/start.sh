#!/bin/sh
if [ -d "/home/Cloudflare-DDNS" ]; then
    cp /home/Cloudflare-DDNS.back/ddns.py /home/Cloudflare-DDNS/ddns.py
    cp -r /home/Cloudflare-DDNS.back/lib /home/Cloudflare-DDNS/
    cp /home/Cloudflare-DDNS.back/ddns-docker /home/Cloudflare-DDNS/ddns-docker
    chmod +x /home/Cloudflare-DDNS/ddns-docker
    cp -r /home/Cloudflare-DDNS.back/conf /home/Cloudflare-DDNS/
    mkdir -p /home/Cloudflare-DDNS/log
    cd /home/Cloudflare-DDNS
fi

while true
do
    ddns_ps=`ps -ef|grep ddns|grep -v grep`
    if [ -z "$ddns_ps" ]
    then
        nohup python /home/Cloudflare-DDNS/ddns.py >> /home/Cloudflare-DDNS/log/DDNS.log 2>&1 &
    fi
    sleep 666
done
