AGENTHOST=$(/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:")
HOSTS="{\"host\" : \""$AGENTHOST"\","
echo $HOSTS > agent-default.conf
echo "
	\"port\": 8689,
	\"maxProcs\": 8,
	\"debugLevel\": 0,

	\"dbConfFilePaths\": [
		\"/app/one.toml\",
	\"/app/two.toml\",
	\"/app/three.toml\",
	\"/app/four.toml\",
	\"/app/five.toml\"
	],
	\"dbClientDialTimeoutSeconds\": 10,
	\"dbClientResponseHeaderTimeoutSeconds\": 20,
	\"dbWriteFailTolerance\": 5,
	\"dbReadFailTolerance\": 3,

	\"scheduler\": {
		\"heartbeatApi\": \"http://pandora:8789/sched/disks\",
		\"heartbeatGapSeconds\": 10,
		\"heartbeatTimeoutSeconds\": 3,
		\"dbWatcherUpdateTimesPerHeartbeat\": 10
	}
}
" >> agent-default.conf

cat agent-default.conf
echo "setup influxdb one"
./influxd -config one.toml > /var/log/pandora/$AGENTHOST.one.out 2>&1 &

echo "setup influxdb two"
./influxd -config two.toml > /var/log/pandora/$AGENTHOST.two.out 2>&1 &

echo "setup influxdb three"
./influxd -config three.toml > /var/log/pandora/$AGENTHOST.three.out 2>&1 &

echo "setup influxdb four"
./influxd -config four.toml > /var/log/pandora/$AGENTHOST.four.out 2>&1 &

echo "setup influxdb five"
./influxd -config five.toml > /var/log/pandora/$AGENTHOST.five.out 2>&1 &
sleep 15

echo "setup agent"
./agent -f agent-default.conf > /var/log/pandora/$AGENTHOST.agent.out 2>&1 
