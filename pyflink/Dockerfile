
FROM flink:1.13.3-scala_2.12

# install python3: it has updated Python to 3.9 in Debian 11 and so install Python 3.7 from source
# it currently only supports Python 3.6, 3.7 and 3.8 in PyFlink officially.

RUN apt-get update -y && \
apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev libffi-dev && \
wget https://www.python.org/ftp/python/3.7.9/Python-3.7.9.tgz && \
tar -xvf Python-3.7.9.tgz && \
cd Python-3.7.9 && \
./configure --without-tests --enable-shared && \
make -j6 && \
make install && \
ldconfig /usr/local/lib && \
cd .. && rm -f Python-3.7.9.tgz && rm -rf Python-3.7.9 && \
ln -s /usr/local/bin/python3 /usr/local/bin/python && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

# install PyFlink

RUN python3 -m pip install apache-flink==1.13.3 

RUN wget -P /opt/flink/lib https://repo.maven.apache.org/maven2/org/apache/flink/flink-json/1.13.3/flink-json-1.13.3.jar; \
    wget -P /opt/flink/lib https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-kafka_2.12/1.13.3/flink-sql-connector-kafka_2.12-1.13.3.jar; \
    wget -P /opt/flink/lib https://repo.maven.apache.org/maven2/org/apache/flink/flink-sql-connector-elasticsearch7_2.12/1.13.3/flink-sql-connector-elasticsearch7_2.12-1.13.3.jar; \
    wget -P /opt/flink/lib https://repo.maven.apache.org/maven2/org/apache/flink/flink-connector-jdbc_2.12/1.13.3/flink-connector-jdbc_2.12-1.13.3.jar; \
    wget -P /opt/flink/lib https://repo.maven.apache.org/maven2/org/postgresql/postgresql/42.2.14/postgresql-42.2.14.jar;

CMD tail -f /dev/null