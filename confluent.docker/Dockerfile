FROM ubuntu:14.04

MAINTAINER Jason Wilder "<jason@influxdb.com>"

# admin, http, udp, cluster, graphite, opentsdb, collectd
EXPOSE 8082 8086 8086/udp 8088 2003 4242 25826 8689

WORKDIR /app

# copy binary into image
COPY confluent-2.0.1-2.11.7.tar.gz /app/
COPY jdk-8u66-linux-x64.tar.gz /app/
RUN tar xvf confluent-2.0.1-2.11.7.tar.gz && tar xvf jdk-8u66-linux-x64.tar.gz
RUN rm confluent-2.0.1-2.11.7.tar.gz
RUN rm jdk-8u66-linux-x64.tar.gz

COPY run.sh /app/
# Add influxd to the PATH
ENV PATH=/app/jdk1.8.0_66/bin:$PATH

ENTRYPOINT ["/bin/bash","-c","bash ./run.sh"]
