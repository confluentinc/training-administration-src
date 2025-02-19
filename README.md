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

## Play with app development!

From this repo, there is a `./data` folder. This folder is mapped to the `/data` folder inside the `tools` container. This means you can create projects inside the `./data` folder on your local machine with your favorite IDE and then run that code from within the `tools` container to interact with the Kafka brokers. We have included a Python producer and a Java consumer. **Your challenge** is to start the cluster, create a topic called `test-topic`, consume from it with the Java consumer, and produce to it with the Python producer in a separate terminal window so you can see the messages in real time. Look at the code and see if you can complete the challenge on your own before reading on. For the Java consumer, look specifically at `src/main/java/app/Consumer.java`, `src/main/resources/consumer.properties`, and `build.gradle`.

Here are the steps to starting the consumer and producer. Within the `tools` container, create the topic and start the consumer:
```
$ docker-compose exec tools bash
root@tools:/# kafka-topics \
                --create --topic test-topic \
                --bootstrap-server kafka-1:9092 \
                --partitions 6 \
                --replication-factor 1
root@tools:/# cd data/java-consumer
root@tools:/data/java-consumer/# gradle run
```

In another terminal, open a new shell in the `tools` container and start the producer:
```
$ docker-compose exec tools bash
root@tools:/# cd data/python-producer
root@tools:/data/python-producer/# pip install -r requirements.txt
root@tools:/data/python-producer/# python producer.py \
                kafka-1:9092,kafka2:9092,kafka-3:9092 \
                test-topic
```

Now play! If you'd like to create your own Java applications, an easy way is to create a new subdirectory under the `data/` module and run `gradle init` from within your new directory inside the `tools` container. This will create the basics needed for a Java application. Use the contents of the `java-consumer` directory as a template for your new project.

Don't forget to exit the `tools` container and clean up with `docker-compose down -v` on your host.

## Other resources

* [Training Page](https://www.confluent.io/training/)
  * Start with the *free* introductory course for a great conceptual foundation of Kafka!
  * If you want to learn about Kafka administration, see our Administration course!
  * If you already know about Kafka administration, see our Advanced Optimization course!
  * If you want to dig deeper into development, see our Developer course!
  * If you already know a bit about developing Kafka clients, push further with our KSQL and Kafka Streams course!
  * Remember that more courses are being developed all the time! 
* [Confluent Platform quickstart](https://docs.confluent.io/current/quickstart/ce-docker-quickstart.html)
  * This is a great hands-on to get started with the basics!
* [Kafka Connect example](https://github.com/confluentinc/examples/tree/5.3.0-post/mysql-debezium)
  * Kafka Connect the best way to get data in and out of Kafka!
* [Confluent's "examples" repo](https://github.com/confluentinc/examples)
  * Tons of great examples!
* [Kafka Tutorials](https://kafka-tutorials.confluent.io/)
  * Tutorials about how to accomplish specific tasks. A great place to see best practices in code, testing, and artifact building (with Gradle Jib).
* [ksqlDB.io](https://ksqldb.io/)
  * Your one-stop shop for all things ksqlDB (docs, examples, concepts) 
* [Ansible playbook](https://github.com/confluentinc/cp-ansible)
  * Automate configuration!
* [Configurations!](https://docs.confluent.io/current/installation/configuration/index.html)
  * So many configurations! Become friends with the configurations. Brokers. Consumers. Producers. Topics. Oh my! Our docs can generally be a little intimidating at first, but they are really good once you learn where everything is.



