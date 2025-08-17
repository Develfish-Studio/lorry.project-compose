--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Lorry = require('@develfish-repo.utils/lib/Lorry')
local SpringApp = require('@root/lib/SpringApp/SpringApp')
local MinioBucket = require('@root/lib/SpringApp/MinioBucket')

local variables: SpringApp.Unwrapped = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local spring_datasource = service.spring_datasource
local spring_kafka = service.spring_kafka
local openid_client = service.openid_client
local minio_client = service.minio_client

local config = {
  services = {
    [service.name] = {
      image = Meta:coalesce(manifest.image, 'eclipse-temurin:17-jdk-alpine'),
      restart ='unless-stopped',
      deploy = {
        resources = {
          limits = {
            memory = '1G'
          }
        }
      },
      environment = Meta:merge(
        spring_datasource and {
          SPRING_DATASOURCE_URL = spring_datasource.url,
          SPRING_DATASOURCE_USERNAME = spring_datasource.username,
          SPRING_DATASOURCE_PASSWORD = spring_datasource.password,
        },
        spring_kafka and {
          SPRING_KAFKA_BOOTSTRAP_SERVERS = spring_kafka.bootstrap_servers,
          SPRING_KAFKA_CLIENT_ID = spring_kafka.client_id,
        },
        spring_kafka and spring_kafka.admin and {
          SPRING_KAFKA_ADMIN_AUTO_CREATE = spring_kafka.admin.auto_create,
          SPRING_KAFKA_ADMIN_CLIENT_ID = spring_kafka.admin.client_id,
        },
        spring_kafka and spring_kafka.consumer and {
          SPRING_KAFKA_CONSUMER_AUTO_COMMIT_INTERVAL = spring_kafka.consumer.auto_commit_interval,
          SPRING_KAFKA_CONSUMER_AUTO_OFFSET_RESET = spring_kafka.consumer.auto_offset_reset,
          SPRING_KAFKA_CONSUMER_BOOTSTRAP_SERVERS = spring_kafka.consumer.bootstrap_servers,
          SPRING_KAFKA_CONSUMER_CLIENT_ID = spring_kafka.consumer.client_id,
          SPRING_KAFKA_CONSUMER_ENABLE_AUTO_COMMIT = spring_kafka.consumer.enable_auto_commit,
          SPRING_KAFKA_CONSUMER_FETCH_MAX_WAIT = spring_kafka.consumer.fetch_max_wait,
          SPRING_KAFKA_CONSUMER_FETCH_MIN_SIZE = spring_kafka.consumer.fetch_min_size,
          SPRING_KAFKA_CONSUMER_GROUP_ID = spring_kafka.consumer.group_id,
          SPRING_KAFKA_CONSUMER_ISOLATION_LEVEL = spring_kafka.consumer.isolation_level,
          SPRING_KAFKA_CONSUMER_KEY_DESERIALIZER = spring_kafka.consumer.key_deserializer,
          SPRING_KAFKA_CONSUMER_MAX_POLL_INTERVAL = spring_kafka.consumer.max_poll_interval,
          SPRING_KAFKA_CONSUMER_MAX_POLL_RECORDS = spring_kafka.consumer.max_poll_records,
          SPRING_KAFKA_CONSUMER_VALUE_DESERIALIZER = spring_kafka.consumer.value_deserializer,
        },
        spring_kafka and spring_kafka.producer and {
          SPRING_KAFKA_PRODUCER_BOOTSTRAP_SERVERS = spring_kafka.producer.bootstrap_servers,
          SPRING_KAFKA_PRODUCER_CLIENT_ID = spring_kafka.producer.client_id,
          SPRING_KAFKA_PRODUCER_GROUP_ID = spring_kafka.producer.group_id,
          SPRING_KAFKA_PRODUCER_RETRIES = spring_kafka.producer.retries,
          SPRING_KAFKA_PRODUCER_TRANSACTION_ID_PREFIX = spring_kafka.producer.transaction_id_prefix,
        },
        spring_kafka and spring_kafka.listener and {
          SPRING_KAFKA_LISTENER_CLIENT_ID = spring_kafka.listener.client_id,
          SPRING_KAFKA_LISTENER_CONCURRENCY = spring_kafka.listener.concurrency,
          SPRING_KAFKA_LISTENER_TYPE = spring_kafka.listener.type,
        },
        spring_kafka and spring_kafka.retry and {
          SPRING_KAFKA_RETRY_TOPIC_ATTEMPTS = spring_kafka.retry.topic_attempts,
          SPRING_KAFKA_RETRY_TOPIC_BACKOFF_DELAY = spring_kafka.retry.topic_backoff_delay,
          SPRING_KAFKA_RETRY_TOPIC_BACKOFF_MAX_DELAY = spring_kafka.retry.topic_backoff_max_delay,
          SPRING_KAFKA_RETRY_TOPIC_BACKOFF_MULTIPLIER = spring_kafka.retry.topic_backoff_multiplier,
          SPRING_KAFKA_RETRY_TOPIC_BACKOFF_RANDOM = spring_kafka.retry.topic_backoff_random,
          SPRING_KAFKA_RETRY_TOPIC_ENABLED = spring_kafka.retry.topic_enabled,
        },
        minio_client and {
          APP_MINIO_CLIENT_TARGET_SERVER = minio_client.target_server,
          APP_MINIO_CLIENT_ACCESS_KEY = minio_client.access_key,
          APP_MINIO_CLIENT_SECRET_KEY = minio_client.secret_key,
        },
        openid_client and {
          APP_OPENID_CLIENT_CLIENTID = openid_client.client_id,
          APP_OPENID_CLIENT_CLIENTSECRET = openid_client.client_secret,
          APP_OPENID_CLIENT_ISSUERURI = openid_client.issuer_uri,
          APP_OPENID_CLIENT_REDIRECTURI = openid_client.redirect_uri,
        },
        Meta:merge(
          Meta:to_sequence(
            Meta:map_array(
              service.minio_buckets or {},
              function(minio_bucket: MinioBucket.MinioBucket, index)
                local upload_policy: MinioBucket.UploadPolicy = minio_bucket.upload_policy or {}
                return {
                  [`APP_MINIO_BUCKETS_{index - 1}_NAME`] = minio_bucket.name,
                  [`APP_MINIO_BUCKETS_{index - 1}_UPLOAD_POLICY_CONTENT_LENGTH`] =
                    upload_policy.content_length,
                  [`APP_MINIO_BUCKETS_{index - 1}_UPLOAD_POLICY_CONTENT_TYPE`] =
                    upload_policy.content_type,
                }
              end
            )
          )
        ),
        manifest.environment
      ),
      profiles = manifest.profiles,
      ports = manifest.ports,
      networks = manifest.networks,
      volumes = manifest.volumes,
      depends_on = manifest.depends_on,
      links = manifest.links
    }
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
