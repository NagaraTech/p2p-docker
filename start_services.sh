#!/bin/bash
service postgresql start
/app/Zchronod --config /app/config-tempelete.yaml > /var/log/vlc_service.log 2>&1 &
/app/znet $PARAMS > /var/log/p2p_service.log 2>&1
