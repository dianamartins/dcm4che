# Use phusion/baseimage as base image. 

FROM phusion/baseimage:0.9.18

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...
RUN apt-get update --assume-yes --quiet && apt-get install python-software-properties --assume-yes --quiet
RUN \
  echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java7-installer --quiet --assume-yes

RUN apt-get install oracle-java7-set-default --assume-yes --quiet
RUN apt-get update && apt-get install -y maven --quiet --assume-yes

RUN apt-get update --assume-yes --quiet && apt-get install wget

WORKDIR /usr/local/hbase
RUN wget http://mirrors.fe.up.pt/pub/apache/hbase/0.98.19/hbase-0.98.19-hadoop2-bin.tar.gz --quiet
RUN tar -xvzf hbase-0.98.19-hadoop2-bin.tar.gz
RUN rm -f hbase-0.98.19-hadoop2-bin.tar.gz

WORKDIR /usr/local/hadoop

RUN wget http://mirrors.fe.up.pt/pub/apache/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz --quiet
RUN tar -xvzf hadoop-2.7.2.tar.gz
RUN rm -f hadoop-2.7.2.tar.gz

ENV HADOOP_HOME /usr/local/hadoop/hadoop-2.7.2
ENV HBASE_HOME /usr/local/hbase/hbase-0.98.19-hadoop2
ENV CLASSPATH /usr/local/hbase/hbase-0.98.19-hadoop2/lib/*
ENV CLASSPATH $CLASSPATH:/usr/local/hadoop/hadoop-2.7.2/lib/*
ENV CLASSPATH $CLASSPATH:/usr/local/hadoop/hadoop-2.7.2/lib/*
ENV CLASSPATH $CLASSPATH:/home/client/

WORKDIR /home/


#COPY configurations/log4j.properties /usr/local/hbase/hbase-0.98.19-hadoop2/lib/
COPY configurations/* client/
COPY client.sh client/
#COPY *.jar /usr/local/hbase/hbase-0.98.19-hadoop2/lib/	

COPY dcm4che-3.3.8-SNAPSHOT-bin.zip client/

WORKDIR /home/client
RUN mkdir results
RUN unzip dcm4che-3.3.8-SNAPSHOT-bin.zip
RUN rm dcm4che-3.3.8-SNAPSHOT-bin.zip
RUN wget -q ftp://dicom.offis.de/pub/dicom/offis/software/dcmtk/dcmtk360/bin/dcmtk-3.6.0-linux-i686-static.tar.bz2
RUN tar xvjf dcmtk-3.6.0-linux-i686-static.tar.bz2
RUN rm dcmtk-3.6.0-linux-i686-static.tar.bz2
RUN mv dcmtk-3.6.0-linux-i686-static dcmtk


RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && rm -rf /var/cache/oracle-jdk7-installer

