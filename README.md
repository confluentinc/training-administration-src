# training-operations-src

This repo contains the source code needed for Confluent Operations Training for Apache Kafka.

## Start your own Kafka Cluster!

```bash
docker-compose up -d
```

## Stop your cluster

```bash
docker-compose down
```

Or, destroy your cluster completely (lose all topic data):

```bash
docker-compose down -v
```

## The Tools Container

Enter the `tools` container to run commands against the Kafka cluster:

```
docker-compose exec tools /bin/bash
```

## Example commands against cluster

Each command can be run from within the `tools` container.

Create a topic "my-topic":

```bash
kafka-topics \
    --bootstrap-server kafka-1:9092 \
    --create \
    --topic my-topic \
    --replication-factor 3 \
    --partitions 2
```

Create a consumer with `group.id=my-group`:

```bash
kafka-console-consumer \
    --bootstrap-server \
      kafka-3:9092 \
    --group my-group \
    --topic my-topic \
    --from-beginning
```

Create a producer that produces to "my-topic":

```bash
kafka-console-producer \
    --broker-list \
      kafka-1:9092,kafka-2:9092 \
    --topic my-topic
```

Do a producer performance test to topic "my-topic"

```bash
kafka-producer-perf-test \
    --topic my-topic \
    --num-records 1000000 \
    --throughput 10000 \
    --record-size 1000 \
    --producer-props \
      bootstrap.servers=kafka-2:9092

```

How might you do a consumer performance test, I wonder?

## Explore configuration files!

1. Enter the broker host `kafka-1`:

```
docker-compose exec kafka-1 /bin/bash
```
2. Take a look at `server.propertes`:

```bash
root@kafka-1: less /etc/kafka/server.properties
```

This is just an example broker configuration file. For complicated reasons, the actual configuration file the container uses is called `kafka.properties` and is created from environment variables in `docker-compose.yml`. 

3. Take a look at `docker-compose.yml` environment varables and compare that to `kafka.properties`:
```bash
root@kafka-1: less /etc/kafka/kafka.properties
```

4. Other components of the cluster have similar configuration files. Explore them, too! Look up what the configuration properties do in more detail in the [Confluent docs](https://docs.confluent.io/current/installation/configuration/index.html)

## Play with app development

From this repo, there is a `./data` folder. This folder is mapped to the `/data` folder inside the `tools` container. This means you can create projects inside the `./data` folder on your local machine with your favorite IDE and then run that code from within the `tools` container to interact with the Kafka brokers. [Here is an example python producer](https://github.com/confluentinc/confluent-kafka-python/blob/master/examples/producer.py) that uses the C-based `librdkafka` library rather than the native Java library. You can create your own `producer.py` file in `./data`. Then run your app from within the `tools` container:
```bash
pip install confluent-kafka
python /data/producer.py
```

## Other resources

* [Confluent Platform quickstart](https://docs.confluent.io/current/quickstart/ce-docker-quickstart.html#step-6-stop-docker)
* [Kafka Connect example](https://github.com/confluentinc/examples/tree/5.2.1-post/mysql-debezium)
  * Kafka Connect the best way to get data in and out of Kafka!
* [Many other awesome examples](https://github.com/confluentinc/examples)



