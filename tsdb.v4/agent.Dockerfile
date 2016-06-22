FROM ubuntu:14.04

MAINTAINER Jason Wilder "<jason@influxdb.com>"

# admin, http, udp, cluster, graphite, opentsdb, collectd
EXPOSE 8083 8086 8086/udp 8088 2003 4242 25826 8689

WORKDIR /app

# copy binary into image
COPY bin/influxd /app/
COPY bin/agent /app/
COPY bin/one.toml /app/
COPY bin/two.toml /app/
COPY bin/three.toml /app/
COPY bin/four.toml /app/
COPY bin/five.toml /app/
COPY agent.run.sh /app/

# Add influxd to the PATH
ENV PATH=/app:$PATH

ENTRYPOINT ["/bin/bash","-c","bash ./agent.run.sh"]
