#!/bin/bash

cd ../znet

p2p_port=33333
ws_port=23333
rpc_port=13333
base_id="hello"
vlc_port=8050
seed_domain=192.168.50.209

go build
ps -ef | grep 'znet' | grep -v grep | awk '{print $2}' | xargs kill -9

echo "Running seed instance 0"
nohup ./znet --id hello0 --domain ${seed_domain} > znet_${base_id}0.log 2>&1 &

for i in {1..10}
do  
    sleep 1
    id=${base_id}${i}
    ((p2p_port++))
    ((ws_port++))
    ((rpc_port++))
    echo "Running instance $i"
    nohup ./znet --remote tcp://${seed_domain}:33333 \
                 --id ${id} \
                 --vlc ${seed_domain}:$((vlc_port + 100 * i)) \
                 --p2p ${p2p_port} \
                 --ws ${ws_port} \
                 --rpc ${rpc_port} \
                 --remoterpc http://${seed_domain}:13333/rpc13333 \
                 > "znet_${id}.log" 2>&1 &
done
