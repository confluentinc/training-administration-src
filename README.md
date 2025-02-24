# training-administration-src

This repo contains the source code needed for Confluent Administration Training for Apache Kafka.

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

First, enable the container by removing the comments on the `tools` container definition in `docker-compose.yml` . 
Then, enter the `tools` container to run commands against the Kafka cluster:

```
docker-compose exec tools bash
```

Don't forget to exit the `tools` container and clean up with `docker-compose down -v` on your host.

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
    --bootstrap-server \
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
   docker-compose exec kafka-1 bash
    ```
2. Take a look at `server.propertes`:

    ```
    root@kafka-1:/# less /etc/kafka/server.properties
    ```

    This is just an example broker configuration file. For complicated reasons, the actual configuration file the container uses is called `kafka.properties` and is created from environment variables in `docker-compose.yml`. 

3. Take a look at `docker-compose.yml` environment variables and compare that to `kafka.properties`:

    ```
    root@kafka-1:/# less /etc/kafka/kafka.properties
    ```

4. Other components of the cluster have similar configuration files. Explore them, too! Look up what the configuration properties do in more detail in the [Confluent docs](https://docs.confluent.io/current/installation/configuration/index.html)

## Monitor your cluster!

Open up Google Chrome and go to `localhost:9021` to monitor your cluster with Confluent Control Center!

## Other resources

* [Training Page](https://www.confluent.io/training/)
  * Start with the **free** _Apache Kafka Fundamentals_ course for a great conceptual foundation of Kafka!
  * _Apache Kafka Administration by Confluent_
  * _Setting Data in Motion with Confluent Cloud_
  * _Confluent Developers Skills for Building Apache Kafka_
  * _Mastering Flink SQL on Confluent Cloud_
  * Remember that more courses are being developed all the time! 
* [Configurations!](https://docs.confluent.io/current/installation/configuration/index.html)
  * So many configurations! Become friends with the configurations. Brokers. Consumers. Producers. Topics. Oh my! Our docs can generally be a little intimidating at first, but they are really good once you learn where everything is.