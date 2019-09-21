package app;

import java.io.FileInputStream;
import java.io.InputStream;
import java.time.Duration;
import java.util.Arrays;
import java.util.Collection;
import java.util.Properties;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;

/*
Declare serializers and deserializers for record keys and values.
Producers serialize keys and values into byte arrays when sending to Kafka,
    and consumers deserialize the records when they read from Kafka.
Here we only need a string deserializer since we are expecting string keys and values.
*/
import org.apache.kafka.common.serialization.StringDeserializer;

public class Consumer {
    public static void main(String[] args) throws Exception {
        System.out.println("Starting Consumer");

        // Declare list of topics for the consumer to subscribe to.
        final Collection<String> TOPICS = Arrays.asList("test-topic");

        // Get configuration properties from consumer.properties file.
        final Properties settings = new Properties();
        InputStream input = new FileInputStream("src/main/resources/consumer.properties");
        settings.load(input);
        settings.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        settings.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);

        // Create consumer. In brackets we have the key's type and the value's type.
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(settings);

        try {
            // Subscribe to topics.
            consumer.subscribe(TOPICS);

            /*
            Consume records. This is where your business logic goes.
            Here, we simply print the offset, key, and value of each record to standard output.
            */

            while (true) {
                final ConsumerRecords<String,String> records = consumer.poll(Duration.ofMillis(100L));

                for (final ConsumerRecord<String, String> record : records) {

                    final String key = record.key();
                    final String value = record.value();

                    System.out.printf("Record at offset %d:\n\tkey: %s\n\t value: %s\n", record.offset(), key, value);
                }
            }
        } finally {
            System.out.println("*** Ending Consumer ***");
            consumer.close();
        }  
    }
}