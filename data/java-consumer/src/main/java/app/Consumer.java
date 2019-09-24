package app;

import java.io.FileInputStream;
import java.io.InputStream;
import java.time.Duration;
import java.util.Arrays;
import java.util.Collection;
import java.util.Properties;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;

public class Consumer {
    public static void main(String[] args) throws Exception {
        System.out.println("Starting Consumer");

        // Declare list of topics for the consumer to subscribe to.
        final Collection<String> TOPICS = Arrays.asList("test-topic");

        // Get configuration properties from consumer.properties file.
        final Properties settings = new Properties();
        InputStream input = new FileInputStream("src/main/resources/consumer.properties");
        settings.load(input);

        // Create consumer. In brackets we have the key's type and the value's type.
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(settings);

        try {
            // Subscribe to topics.
            consumer.subscribe(TOPICS);

            /*
            Consume records. This is where your business logic goes.
            Here, we simply print the partition, offset, key, and value
            of each record to standard output.
            */

            while (true) {
                final ConsumerRecords<String,String> records = consumer.poll(Duration.ofMillis(100L));

                for (final ConsumerRecord<String, String> record : records) {

                    final String key = record.key();
                    final String value = record.value();

                    System.out.printf(
                        "Record information:\npartition: %d\noffset: %d\nkey: %s\nvalue: %s\n",
                            record.partition(),
                            record.offset(),
                            key,
                            value
                        );
                }
            }
        } finally {
            System.out.println("*** Ending Consumer ***");
            consumer.close();
        }  
    }
}