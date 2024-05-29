#!/bin/bash

cd ../chronos

mkdir scripts & cd scripts

export PGUSER="postgres"
export PGPASSWORD=""
export PGHOST="0.0.0.0"
export PGPORT="5432"

pg_db_url="postgres://${PGUSER}:${PGPASSWORD}@${PGHOST}:${PGPORT}"

# 0. generate_configs.sh

for i in {0..10}
do
cat <<EOL > config-template$i.yaml
pg_db_url: "${pg_db_url}"
pg_db_name: "vlc_inner_db$i"
outer_p2p: "0.0.0.0:$((8051 + 100 * i))"
inner_p2p: "0.0.0.0:$((8050 + 100 * i))"
ws_url: "0.0.0.0:$((8052 + 100 * i))"
read_maximum: 20
node_id: "hello$i"
EOL
done

# 1. kill zchronod process
ps -ef | grep 'zchronod' | grep -v grep | awk '{print $2}' | xargs kill -9

# 2. dropdb
base_id="vlc_inner_db"

for i in {0..10}
do
    db=$base_id$i
    dropdb ${db};
done

# 3. createdb
base_id="vlc_inner_db"

for i in {0..10}
do
    db=$base_id$i
    createdb ${db};
done

# 4. init pg db
for i in {0..10}
do
    ../target/debug/zchronod --init_pg ${pg_db_url}/vlc_inner_db$i
done

# 5. run zchronod
for i in {0..10}
do
		nohup ../target/debug/zchronod --config config-template$i.yaml > zchronod_hello$i.log 2>&1 &
done
