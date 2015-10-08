#! /bin/bash

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -e HOST_IP=$1 -e ZK=$2 -i -t wurstmeister/kafka:0.8.2.0 /bin/bash -c "echo -n '`cat $3`' | \$KAFKA_HOME/bin/kafka-console-producer.sh --topic sample-topic --broker-list=\`broker-list.sh\`"

