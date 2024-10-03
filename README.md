# Instabug chat system

## **Table of Contents**

1. [Overview](#overview)
2. [How to Run the Project Locally](#how-to-run-the-project-locally)
3. [What is the overall structure of your code?](#02-what-is-the-overall-structure-of-your-code)

## Overview
This repository contains a chat system developed as a task for Instabug, utilizing Ruby on Rails and Mysql.

### Features
- **Sidekiq Integration**: Uses Sidekiq for background job processing, allowing asynchronous handling of message queuing and request processing.
- **Elasticsearch Search**: Integrates Elasticsearch to enable efficient full-text search for messages.
- **API**: Offers a RESTful API with CRUD operations for managing applications, chats, and messages.
- **Containerization**: Employs Docker Compose for streamlined deployment and scalability.
- **MySQL**: Stores all data in MySQL, ensuring compatibility with Rails.
- **Scheduled Task**: Includes a cron job that runs hourly to synchronize chat and message counts.

## How to run the project locally

### Setup
1. **Clone the repo**
   ```
   git clone https://github.com/badrannn/instabug_task_chat_system.git
   cd instabug_task_chat_system
   ```
2. **Run the project with Docker**
   ```
   docker-compose up --build
   ```
### API endpoints
_your project should be running over localhost:3000_

#### Applications
- **Update Application**  (only permissible to modify the name through a JSON body)
  
  `PATCH /applications/:token`

  **Example Request Body:**
  
   ```json
   {
       "application": {
           "name": "updated_name"
       }
   }
  

- **Create Application**  
  `POST /applications`

   **Example Request Body:**
  
   ```json
   {
       "application": {
           "name": "example_name"
       }
   }


- **Show Application**  (__nested associated resources__)

  `GET /applications/:token`

  **Example response**
  ```json
   {
    "name": "test_3",
    "token": "kcbR52tHqNJ11pDCYoMP6A",
    "chats_count": 0,
    "chats": [
        {
            "number": 1,
            "messages_count": 0,
            "messages": [
                {
                    "number": 1,
                    "body": "testing"
                },
                {
                    "number": 2,
                    "body": "testing_2"
                }
            ]
        },
        {
            "number": 2,
            "messages_count": 0,
            "messages": []
        }
    ]



#### Chats
- **List Chats**  
  `GET /applications/:application_token/chats`
   **Example Request Body:**
  
   ```json
   [
    {
        "number": 1,
        "messages_count": 2,
        "messages": [
            {
                "number": 1,
                "body": "testing"
            },
            {
                "number": 2,
                "body": "testing_2"
            }
        ]
    },
    {
        "number": 2,
        "messages_count": 0,
        "messages": []
    },
    {
        "number": 3,
        "messages_count": 0,
        "messages": []
    }


- **Create Chat**  
  `POST /applications/:application_token/chats` **--> Returns: chat_number**

- **Show Chat**  
  `GET /applications/:application_token/chats/:number`

   **Example response:**
   ```json
   {
    "number": 1,
    "messages_count": 0,
    "messages": [
        {
            "number": 1,
            "body": "testing"
        },
        {
            "number": 2,
            "body": "testing_2"
        }
    ]



#### Messages
- **List Messages**  
  `GET /applications/:application_token/chats/:chat_number/messages`


  **Example response:**
  
   ```json
  
  [
    {
        "number": 1,
        "body": "testing"
    },
    {
        "number": 2,
        "body": "testing_2"
    }


- **Create Message**  
  `POST /applications/:application_token/chats/:chat_number/messages`

  **Example Request Body:**
  
   ```json
   {
       "message": {
           "body": "sample_content"
       }
   }
  

- **Show Message**  
  `GET /applications/:application_token/chats/:chat_number/messages/:number`

  **Example response:**
  
   ```json
  {
    "number": 1,
    "body": "testing"
  }
  

- **Search Messages**  (Utilizes ElasticSearch)

  `GET /applications/:application_token/chats/:chat_number/messages/search?query=your_query`

  **Example response:**
  ```json
  
  [
    {
        "number": 1,
        "body": "testing"
    },
    {
        "number": 2,
        "body": "testing_2"
    }

