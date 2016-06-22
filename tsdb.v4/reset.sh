 echo "[setup] stop agent1"
 docker rm -f agent1
 echo "[setup] stop agent2"
 docker rm -f agent2
 echo "[setup] stop agent3"
 docker rm -f agent3
 echo "[setup] stop pandora"
 docker rm -f pandora
 echo "[setup] stop confluent"
 docker rm -f confluent

sudo rm /var/log/pandora/*

echo "[setup] start confluent"
docker run -d --name confluent -p 8082:8082 confluent
sleep 8

echo "[setup] start pandora.v4"
echo "[cmd]docker run --name pandora -p 8789:8789 -p 9091:9091 -p 9092:9092 -p 9090:9090 -p 6060:6060 --link confluent:confluent -v /var/log/pandora:/var/log/pandora -d pandora.v4
"
docker run --name pandora -p 8789:8789 -p 9091:9091 -p 9092:9092 -p 9090:9090 --link confluent:confluent -v /var/log/pandora:/var/log/pandora -d pandora.v4
sleep 8

echo "[setup] start agent"
echo "[cmd] docker run --name agent1 -v /var/log/pandora:/var/log/pandora --link pandora:pandora -d 10.200.20.41/pandora_tsdb/agent"
 docker run --name agent1 -v /var/log/pandora:/var/log/pandora --link pandora:pandora -d 10.200.20.41/pandora_tsdb/agent
sleep 1
 docker run --name agent2 -v /var/log/pandora:/var/log/pandora --link pandora:pandora -d 10.200.20.41/pandora_tsdb/agent 
sleep 1
 docker run --name agent3 -v /var/log/pandora:/var/log/pandora --link pandora:pandora -d 10.200.20.41/pandora_tsdb/agent
sleep 1

DOCKERHOST=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' pandora)

echo ">>> pandora serve at:" 
echo $DOCKERHOST

sleep 40
echo "[verify] verify groups"
curl -G "http://"$DOCKERHOST":8789/sched/stats?q=groups"

echo "[verify] create repo:v4test"
curl -X POST -H "Content-Type: application/json" -H "X-Appid: 1" -H "Authorization: QiniuStub uid=1&ut=4" -d '{
    "region":"nb"
}' "http://"$DOCKERHOST":9091/v4/repos/v4test"

echo "[verify] create series:cputest"
curl -X POST -H "Content-Type: application/json" -H "X-Appid: 1" -H "Authorization: QiniuStub uid=1&ut=4"  -d '{
    "retention":"oneDay"
}' "http://"$DOCKERHOST":9091/v4/repos/v4test/series/cputest"

echo "[verify] write points"
curl -X POST -H "Authorization: QiniuStub uid=1&ut=4" -H "X-Appid: 1" -H "Content-Type: text/plain" \
 -d 'cputest,host=h1 value=123' "http://"$DOCKERHOST":9092/v4/repos/v4test/points"

echo "[verify] create view"
 curl -X POST -H "X-Appid: 1" -H "Content-Type: application/json" -d '{
    "retention":"oneDay",
    "sql":"select mean(value) as value.abc into testview from cputest group by time(1m)"
}' "http://"$DOCKERHOST":9091/v4/repos/v4test/views/testview"

echo "[verify] write points"
curl -X POST -H "Authorization: QiniuStub uid=1&ut=4" -H "X-Appid: 1" -H "Content-Type: text/plain" \
 -d 'cputest,host=h1 value=123' "http://"$DOCKERHOST":9092/v4/repos/v4test/points"
echo "[verify] write points"
curl -X POST -H "Authorization: QiniuStub uid=1&ut=4" -H "X-Appid: 1" -H "Content-Type: text/plain" \
 -d 'cputest,host=h1 value=123' "http://"$DOCKERHOST":9092/v4/repos/v4test/points"

echo "[verify] query data"
curl -X POST -H "Content-Type: text/plain" -H "X-Appid: 1" -H "Authorization: QiniuStub uid=1&ut=4"  \
 -d 'select * from cputest' "http://"$DOCKERHOST":9092/v4/repos/v4test/query"

echo "[verify] query view series"
curl -X POST -H "Content-Type: text/plain" -H "X-Appid: 1" -H "Authorization: QiniuStub uid=1&ut=4"  \
 -d 'select * from testview' "http://"$DOCKERHOST":9092/v4/repos/v4test/query"
