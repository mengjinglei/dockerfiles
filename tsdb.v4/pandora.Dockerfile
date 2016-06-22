FROM ubuntu:14.04
MAINTAINER <mengjinglei@qiniu.com> (mengjinglei)

RUN /bin/bash -c 'source $HOME/.bashrc ; echo $HOME'

RUN apt-get update > /dev/null && apt-get install -y \
  wget \
  mongodb \
  memcached \
  curl \
  --no-install-recommends > /dev/null

WORKDIR /app

# Install Etcd
COPY bin/etcd-v2.2.5-linux-amd64.tar.gz /app/
RUN tar xvf etcd-v2.2.5-linux-amd64.tar.gz
RUN mv etcd-v2.2.5-linux-amd64 /usr/local/etcd
ENV PATH /usr/local/etcd:$PATH

RUN service memcached restart

RUN service mongodb restart

EXPOSE 8083 8086 8086/udp 8088 2003 4242 25826

COPY bin/mgr /app/
COPY bin/mgr-default.conf /app/
COPY bin/pointd /app/
COPY bin/pointd-default.conf /app/
COPY bin/sched /app/
COPY bin/sched-default.conf /app/
COPY bin/producer /app/
COPY bin/producer-default.conf /app/
COPY bin/adapter /app/
COPY bin/adapter-default.conf /app/
COPY pandora.run.sh /app/
EXPOSE 9090 9091 9092 8789
ENTRYPOINT ["/bin/bash","-c","bash ./pandora.run.sh"]

