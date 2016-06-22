export GOPATH=/home/qiniu/go/default:/home/qiniu/go/base/qiniu:/home/qiniu/go/base/docs:/home/qiniu/go/base/com:/home/qiniu/go/base/biz:/home/qiniu/go/base/portal:/home/qiniu/go/base/cgo:/home/qiniu/go/pandora:/home/qiniu/go/pandora-sdk:/home/qiniu/go/streaming:/home/qiniu/go/pandora

cd /home/qiniu/go/pandora/src/qiniu.com/pandora/pandora.v4
TARGET=/home/qiniu/go/dockerfiles/tsdb.v4/bin

cd agent
GOOS=linux GOARCH=amd64 go build -o  agent
mv agent $TARGET

cd ../consumer/main
GOOS=linux GOARCH=amd64 go build -o  adapter
mv adapter $TARGET
#cp adapter-default.conf ../../dockerfiles/bin

cd ../../mgr/main
GOOS=linux GOARCH=amd64 go build -o  mgr -a
mv mgr $TARGET
cp mgr-default.conf $TARGET

cd ../../pointd/main
GOOS=linux GOARCH=amd64 go build -o  pointd -a
mv pointd $TARGET
sed 's|127.0.0.1:8082|confluent:8082|g' -i pointd-default.conf
cp pointd-default.conf $TARGET

cd ../../sched/main
GOOS=linux GOARCH=amd64 go build -o  sched -a
mv sched $TARGET
cp sched-default.conf $TARGET

cd /home/qiniu/go/dockerfiles/tsdb.v4

echo "start to build pandora.v4"
docker build -t pandora.v4 -f pandora.Dockerfile .
echo "start to build agent"
docker build -t agent -f agent.Dockerfile .
