DROM java:8-jre
MAINTAINER "30040852@qq.com"
 
RUN groupadd -r elasticsearch && useradd -r -g elasticsearch elasticsearch
 
ENV GOSU_VERSION 1.10
 
RUN set -ex \
    && mkdir -p /usr/local/java \
    && mkdir -p /usr/local/data \
    && mkdir -p /usr/local/data/elasticsearch \
    && mkdir -p /usr/local/data/elasticsearch/data \
    && mkdir -p /usr/local/data/elasticsearch/logs
 
RUN set -x \
    && apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && apt-get purge -y --auto-remove ca-certificates wget
 
COPY /soft/elasticsearch-6.1.3.tar.gz /usr/local/elasticsearch-6.1.3.tar.gz
COPY /soft/jdk-8u181-linux-x64.tar.gz /usr/local/jdk-8u181-linux-x64.tar.gz
 
RUN tar xzf /usr/local/jdk-8u181-linux-x64.tar.gz -C /usr/local/java/ && rm -rf /usr/local/jdk-8u181-linux-x64.tar.gz
RUN tar xzf /usr/local/elasticsearch-6.1.3.tar.gz -C /usr/local/ && rm -rf /usr/local/elasticsearch-6.1.3.tar.gz
 
ENV JAVA_HOME /usr/local/java/jdk1.8.0_181
ENV CLASSPATH .:%JAVA_HOME%\lib:%JAVA_HOME%\lib\dt.jar:%JAVA_HOME%\lib\tools.jar
ENV PATH /usr/local/elasticsearch-6.1.3/bin:%JAVA_HOME%\bin:%JAVA_HOME%\jre\bin:$PATH
 
WORKDIR /usr/local/elasticsearch-6.1.3
 
RUN set -ex \
    && for path in \
        ./data \
        ./logs \
        ./config \
        ./config/scripts \
    ; do \
        mkdir -p "$path"; \
        chown -R elasticsearch:elasticsearch "$path"; \
        chown -R elasticsearch:elasticsearch /usr/local/data; \
        chown -R elasticsearch:elasticsearch /usr/local/elasticsearch-6.1.3; \
        chown -R elasticsearch:elasticsearch /usr/local/data/elasticsearch/data; \
        chown -R elasticsearch:elasticsearch /usr/local/data/elasticsearch/logs; \
    done
 
COPY /config/elasticsearch.yml ./config/elasticsearch.yml
 
VOLUME /usr/local/elasticsearch-6.1.3/data
 
COPY docker-entrypoint.sh /
 
RUN chmod 777 /docker-entrypoint.sh
 
EXPOSE 9200 9300
 
ENTRYPOINT ["/docker-entrypoint.sh"]
 
CMD ["elasticsearch"]











