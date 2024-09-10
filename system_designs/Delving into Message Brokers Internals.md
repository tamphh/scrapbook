## Understanding a Message Queue, Communication Models, Pros and Cons.
![image](https://github.com/user-attachments/assets/9127635e-9f53-4cee-939b-566c0f6b1962)


## Introduction

Message brokers are one of the most important components of modern software architecture. Understanding them is key to designing reliable services that can handle high loads, multiple long-running tasks, and support asynchronous communication.

In this article, I will focus on the concept of a queue-based message broker, one of the most popular broker implementations.

## Message queue

Before we delve into message broker details, we must understand its fundamental part — the message queue.

A [message queue](https://en.wikipedia.org/wiki/Message_queue) (MQ) is a component used in distributed systems to enable asynchronous communication. In essence, it’s a [queue data structure](https://en.wikipedia.org/wiki/Queue_(abstract_data_type)) (`[FIFO](https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics))` order) that accepts and stores messages until they are processed by an application.

![image](https://github.com/user-attachments/assets/263053a1-a358-4d18-9df6-3c993a89eee7)

Example of a message queue

A message represents a unit of data that is sent from one application to another through a message queue.

It may be sent with various data types (`text`, `binary`, `JSON`, etc.) and includes a message body, headers, and other configuration properties such as delivery mode, acknowledgment, designation queue, policies, etc.

Messages fall into several categories depending on their purpose:

-   [Commands](https://www.enterpriseintegrationpatterns.com/patterns/messaging/CommandMessage.html): These messages are intended to transfer a specific action to the consumer. They often carry action names such as `create_order`, and additional details to process requests. A command message implies one consumer.

```js
{
  "command": "create_order",
  "order_id": "1573b634-b1fc-4e72–8f57–86ec461391d7",
  "customer_id": "a84abe57-e7f9–4619-a7e9–4f08652849f2",
  "products": [
    {
      "product_id": "2f5f32f2–3818–4876-aa77-a87d0f309498",
      "quantity": 2
    },
    {
      "product_id": "f50f8aff-0f2d-4a30–8bbb-1040c1b723a5",
      "quantity": 1
    }
  ],
  "total_amount": 49.99,
  "timestamp": "2024–02–27T12:00:00Z"
}
```

-   [Events](https://www.enterpriseintegrationpatterns.com/patterns/messaging/EventMessage.html): This is a special type of message to represent a state change. Oftentimes, events don’t need additional context because the event itself is sufficient and more valuable than the data contained within it.

```js
{
  "event_type": "package_status_changed",
  "package_id": "PKG123456789",
  "status": "delivered",
  "location": "123 Main St, Anytown, USA",
  "timestamp": "2024–02–27T15:30:00Z"
}
```

-   [Documents](https://www.enterpriseintegrationpatterns.com/patterns/messaging/DocumentMessage.html): A document is a message intended to pass data and let the receiver decide what to do. A document message itself can be any kind of message, e.g. serializable domain object. This type of message implies one zero or n consumers.

The main difference between a document message and an event message is that in a document message, the content is more important than the sending/receiving time.

```js
{
  "id": "1573b634-b1fc-4e72–8f57–86ec461391d7",
  "product_name": "Smartphone X",
  "description": "A high-performance smartphone with advanced features.",
  "price": 599.99,
  "category": "Electronics",
  "brand": "TechCo",
  "availability": true,
  "timestamp": "2024–02–27T10:00:00Z"
}
```

-   Queries: It’s a special type of command to retrieve information. A query command implies one consumer.

```js
{
  "type": "get_order",
  "order_id": "1573b634-b1fc-4e72–8f57–86ec461391d7",
}
```

-   Replies: Reply messages are the response to a command or query message. The response address is typically sent along with the request message, and when the consumer has processed the message, it sends it back to its destination. A reply message implies one consumer.

Command message:

```js
{
  "message_type": "command",
  "command_type": "fetch_user_data",
  "user_id": "123456",
  "response_address": "response_queue",
  "timestamp": "2024–02–27T13:00:00Z"
}
```

Reply message:

```js
{
  "message_type": "response",
  "request_id": "14892cf3-656b-462c-98d0-6df5124bf915",
  "user_id": "123456",
  "name": "John Doe",
  "email": "john.doe@example.com",
  "address": "123 Main St, Anytown, USA",
  "timestamp": "2024–02–27T13:05:00Z"
}
```

![image](https://github.com/user-attachments/assets/ac5ee082-60ac-4789-9933-df08e8f7cb16)

The five main message types

To standardize communication between systems using a message queue, one of these protocols is often used:

-   [Advanced Message Queuing Protocol](https://en.wikipedia.org/wiki/Advanced_Message_Queuing_Protocol) (AMQP): AMQP is an open standard messaging protocol designed for message-oriented middleware environments.
-   [Streaming Text Oriented Messaging Protocol](https://en.wikipedia.org/wiki/Streaming_Text_Oriented_Messaging_Protocol) (STOMP): STOMP is a text-based messaging protocol that defines a format for sending and receiving messages between clients and message brokers.
-   [MQ Telemetry Transport](https://en.wikipedia.org/wiki/MQTT) (MQTT): MQTT is a lightweight publish-subscribe messaging protocol designed for IoT (Internet of Things) applications and low-bandwidth, high-latency, or unreliable networks.

MQ systems ensure reliable and ordered delivery of messages, typically providing features like persistence, message acknowledgment, and guaranteed delivery.

## Message broker

A message broker is an intermediary software component responsible for facilitating communication between different applications or components by routing, transforming, and usually storing messages.

It acts as a middleware ([MOM](https://en.wikipedia.org/wiki/Message-oriented_middleware)) where producers (applications that send messages) and consumers (applications that receive messages) can connect without being aware of each other.

Most message brokers are based on a message queue, although they may support a different structure, e.g., log-based, or other ordering using stacks, priority or delay features, etc.

![image](https://github.com/user-attachments/assets/ae765d33-e710-4eb1-9b11-33a5029bbef0)

The relationship between message broker and message queue

On top of that, they provide additional features such as message filtering, routing based on message content, protocol translation, and message transformation.

To receive a message from a broker, there are two options: `pull` and `push`. With `pull` clients manually request the broker to receive the message, while with `push` clients subscribe to the broker, and the broker sends the message automatically.

Popular examples of queue-based message brokers include RabbitMQ, ActiveMQ, IBM MQ, Amazon SQS, Redis, EMQX.

## Message sending patterns:

When employing a broker, there are two main messaging patterns: `P2P` and `Pub/Sub`. These patterns describe a relation between the sender and receiver.

Each of them typically supports asynchronous `fire-and-forget` and asynchronous `request-response` communication methods which are focused on the overall message flow.

You can see the difference between them in each messaging pattern below, but in short, with the `fire-and-forget` strategy message sender does not expect to receive a response from the consumer.

## P2P (work/task queue)

[Point-to-point](https://en.wikipedia.org/wiki/Point-to-point_(telecommunications)) (P2P) is a messaging pattern used to enable a one-to-one communication strategy.

In that type of communication, a producer must know a destination (queue).

![image](https://github.com/user-attachments/assets/4fe7f93a-f0e2-467f-95d0-6f7d793cced4)

Example of point-to-point communication with the fire-and-forget approach

Because the `P2P` messaging pattern guarantees that only one client will receive a message from a queue, typical load balancing between consumers is done using the [round-robin algorithm](https://en.wikipedia.org/wiki/Round-robin_scheduling).

![image](https://github.com/user-attachments/assets/30df95c2-8491-4a7a-96ff-bf8e4b64c77a)

Point-to-point communication with multiple consumers

> It is worth noting that when there are multiple consumers, messages do not always go in `FIFO` order — one consumer may take longer to process messages than another and thus disrupt the order.

In the `request-response` type of messaging, a message publisher sends a message to one queue (request queue) and then waits, usually blocking the dedicated thread, for a response in another queue (response queue).

![image](https://github.com/user-attachments/assets/2bceef12-906c-40ee-8ef6-f931e69ae3d5)

Example of point-to-point communication with the request/response approach

## Pub/Sub

[Publish/Subscribe](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern) (Pub/Sub) is a messaging pattern used to enable a one-to-many communication strategy.

In the typical `Pub/Sub` communication, there is a producer (also called a publisher) and a consumer (subscriber). The producer sends a message to a topic, and then the broker broadcasts it to all interested subscribers.

![image](https://github.com/user-attachments/assets/fea71cf6-5652-43c3-9600-acadcbca96d7)

Example of typical Pub/Sub communication

When we use the `Pub/Sub` model with message queueing, it creates one or several queues in front of subscribers. In such a way, the broker combines broadcast transmission with a delivery guarantee.

![image](https://github.com/user-attachments/assets/e60ed91b-2c1e-42b8-9a13-66c801c98d9f)

Pub/Sub communication with message retention

Here, you can see the difference between the `P2P` and the `Pub/Sub` patterns:

1.  In the `P2P` a producer should know the exact queue to send for, whereas in the `Pub/Sub` a producer should know only the topic.
2.  In a `Pub/Sub` strategy, all consumers subscribed to the same topic receive their own copy of the message, whereas in `P2P`, even if multiple consumers subscribe to the same queue, only one of them will receive the message at a single point in time.

## Pros and cons

The message broker plays an important role in various distributed system architectures, but like any other technology, it has its trade-offs.

**Pros:**

-   Long-running task and pick load surviving: When a large volume of messages is received from producers, the message broker can preserve them, ensuring that downstream services are not overloaded.
-   Decoupling of applications: Message brokers enable decoupling between applications or services by acting as intermediaries for communication. This decoupling allows applications to interact without needing to know the specifics of each other’s implementations, leading to more modular and scalable architectures.
-   Asynchronous communication: Because message brokers act as middleware, they facilitate asynchronous communication between components, where messages are sent and received without requiring both parties to be actively available at the same time.
-   Load balancing and scaling: Message brokers can distribute messages across multiple consumers, enabling load balancing and horizontal scaling of processing tasks. This capability is especially valuable in scenarios with high message throughput or variable processing demands.
-   Microservices communication: In microservices architectures, message brokers are commonly used for inter-service communication, allowing microservices to communicate asynchronously without direct dependencies on each other.

**Cons:**

-   Steep learning curve: While the total concept of message brokers may be easy to understand, actual adoption is not that simple. There are many nuances to consider: what type of message broker will be more appropriate, what configuration will be used, etc.
-   Overall system complexity: Integrating a message broker into a system leads to increased architectural complexity. It includes refactoring existing communication, adding security options, complicated debugging, etc. Also, introducing a message broker may slow down existing message communication because of the additional component in the middle. So now you rely on eventual consistency, instead of immediate data processing and access.

## Summing up

In this article, we have looked at the message queue, which is the key mechanism of most brokers, different types of messages, the message broker, types of communication between the broker and clients, and the pros and cons of using it.

source: https://levelup.gitconnected.com/delving-into-message-brokers-internals-deeb23a20ff0
