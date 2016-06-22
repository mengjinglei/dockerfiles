service memcached restart

mkdir -p /data/db/ && mongod --noprealloc --smallfiles > mongo.out 2>&1 &

etcd > etcd.out 2>&1 &

tryTime=1
maxtryTime=20 #最多等待20次，100s，超过就认为启动mongodb失败
ls
while true
do
        sleep 5
        if grep "waiting for connections" mongo.out > /dev/null
        then
                echo 'MongoDB started!'
                break
        else
                echo "MongoDB is starting...  wait for five more second"
                let tryTime++
                if [ $tryTime -gt $maxtryTime ] 
                then
                  echo $tryTime
                  echo $maxtryTime
                  echo "starting MongoDB failed."
                  break
                fi
        fi
done

PANDORAHOST=$(/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")

curl -L http://127.0.0.1:4001/v2/keys/tsdb_adapter_dir -d dir=true
curl -L http://127.0.0.1:2379/v2/keys/tsdb_adapter_dir/tsdb-adapter/0 -XPUT -d value="0"
curl -L http://127.0.0.1:2379/v2/keys/tsdb_adapter_dir/tsdb-adapter/1 -XPUT -d value="0"
curl -L http://127.0.0.1:2379/v2/keys/tsdb_adapter_dir/tsdb-adapter1/0 -XPUT -d value="0"
curl -L http://127.0.0.1:2379/v2/keys/tsdb_adapter_dir/tsdb-adapter1/1 -XPUT -d value="0"
curl -L http://127.0.0.1:2379/v2/keys/tsdb_adapters/adapter1/tsdb-adapter/0 -XPUT -d value="http://confluent:8082"
curl -L http://127.0.0.1:2379/v2/keys/tsdb_adapters/adapter1/tsdb-adapter/1 -XPUT -d value="http://confluent:8082"

#audi log
curl -XPUT http://127.0.0.1:2379/v2/keys/configs/audit_config/sched  -d value='{"logdir":"./run/auditlog/sched","chunkbits": 29}'
#db config
curl -XPUT http://127.0.0.1:2379/v2/keys/configs/db_config/pandora_tsdb  -d value='{"host" : "127.0.0.1:27017", "db" : "pandora_tsdb"}'
#qconf
curl -XPUT http://127.0.0.1:2379/v2/keys/configs/qconf_config/sched -d value='{"mc_hosts":["127.0.0.1:11211","127.0.0.1:11211","127.0.0.1:11211"]}'
#service
curl -XPUT http://127.0.0.1:2379/v2/keys/configs/service_config/sched -d value='{ "port" : ":8789", "max_procs" : 8, "debug_level" : 0}'
#sched
curl -XPUT http://127.0.0.1:2379/v2/keys/configs/custom_module_config/sched/dispatch_config -d value='{"groupOffset": "720h","checkInterval": "30s", "heartbeatInterval":"60s","strategy": "default", "freeGroupSize": 10, "switchGroupTime": 3600, "autoSwitch": false, "replica": 3}'
#retention
curl -XPUT http://127.0.0.1:2379/v2/keys/configs/custom_module_config/sched/retention_config -d value='[{"name":"oneDay", "duration":"24h", "replica": 1},{"name":"oneWeek", "duration":"1w", "replica":1},{"name":"oneMonth", "duration":"30d","replica": 1},{"name":"oneYear", "duration":"365d","replica": 1},{"name":"forever", "duration":"INF", "replica":1} ]'
#locks
curl -XPUT http://127.0.0.1:2379/v2/keys/configs/custom_module_config/sched/locks_config -d value='{"distributeLockTTl" : 5,"masterElectionTTL" : 15,"longestLockTimeToLive" : 1800}'

mkdir -p run/auditlog/mgr
mkdir -p run/auditlog/sched
mkdir -p run/auditlog/pointd
mkdir -p run/auditlog/adapter
./mgr -f mgr-default.conf > /var/log/pandora/$PANDORAHOST.mgr.out 2>&1 &
sleep 1
./sched -f sched-default.conf > /var/log/pandora/$PANDORAHOST.sched.out 2>&1 &
sleep 1
./pointd -f pointd-default.conf > /var/log/pandora/$PANDORAHOST.pointd.out 2>&1 &
sleep 1
./adapter -f adapter-default.conf > /var/log/pandora/$PANDORAHOST.adapter.out 2>&1
sleep 1
