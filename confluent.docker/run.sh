cd /app/confluent-2.0.1
./bin/zookeeper-server-start ./etc/kafka/zookeeper.properties > zookeeper-server.out 2>&1 &
sleep 2
./bin/kafka-server-start ./etc/kafka/server.properties > kafka-server.out 2>&1 &
sleep 2
./bin/kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 2 --topic tsdb-adapter
./bin/kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 2 --topic tsdb-adapter1
./bin/kafka-topics --create --zookeeper localhost:2181 --replication-factor 1 --partitions 2 --topic testAdditionTopic
./bin/schema-registry-start ./etc/schema-registry/schema-registry.properties > schema-registry.out 2>&1  &
sleep 2
./bin/kafka-rest-start ./etc/kafka-rest/kafka-rest.properties 
sleep 2
# go back 
cd -
