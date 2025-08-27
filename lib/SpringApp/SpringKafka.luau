--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local PropTypes = require('@develfish-repo.project/lib/PropTypes')

local SpringKafka = {}

export type SpringKafka = typeof(SpringKafka)

export type SpringKafkaAdminProps = {
  auto_create: string?,
  client_id: string?,
}

export type SpringKafkaProducerProps = {
  bootstrap_servers: string?,
  client_id: string?,
  group_id: string?,
  retries: string?,
  transaction_id_prefix: string?,
}

export type SpringKafkaConsumerProps = {
  auto_commit_interval: string?,
  auto_offset_reset: string?,
  bootstrap_servers: string?,
  client_id: string?,
  enable_auto_commit: string?,
  fetch_max_wait: string?,
  fetch_min_size: string?,
  group_id: string?,
  isolation_level: string?,
  key_deserializer: string?,
  max_poll_interval: string?,
  max_poll_records: string?,
  value_deserializer: string?,
}

export type SpringKafkaListenerProps = {
  client_id: string?,
  concurrency: string?,
  type: string?,
}

export type SpringKafkaTemplateProps = {
  default_topic: string?,
  observation_enabled: string?,
  transaction_id_prefix: string?,
}

export type SpringKafkaRetryProps = {
  topic_enabled: string?,
  topic_attempts: string?,
  topic_backoff_delay: string?,
  topic_backoff_random: string?,
  topic_backoff_max_delay: string?,
  topic_backoff_multiplier: string?,
}

export type SpringKafkaProps = {
  bootstrap_servers: string,
  client_id: string?,
  admin: SpringKafkaAdminProps?,
  consumer: SpringKafkaConsumerProps?,
  listener: SpringKafkaListenerProps?,
  producer: SpringKafkaProducerProps?,
  retry: SpringKafkaRetryProps?,
  template: SpringKafkaTemplateProps?,
}

export type Unwrapped = SpringKafkaProps

export type SpringKafkaImpl = SpringKafka & SpringKafkaProps & Wrapper.Unwrappable<Unwrapped>

function SpringKafka:new(o: SpringKafkaProps): SpringKafka
  return Meta:type(o, self, 'SpringApp.SpringKafka')
end

function SpringKafka:from_bootstrap(bootstrap_servers: string): SpringKafka
  return SpringKafka:new({
    bootstrap_servers = bootstrap_servers
  })
end

function SpringKafka:from_remote(props: PropTypes.KafkaRemote): SpringKafka
  return SpringKafka:new({
    bootstrap_servers = props.bootstrap_servers
  })
end

function SpringKafka:with_consumer_props(props: SpringKafkaConsumerProps): SpringKafka
  local this = self::SpringKafkaImpl
  this.consumer = props
  return this
end

function SpringKafka:with_producer_props(props: SpringKafkaProducerProps): SpringKafka
  local this = self::SpringKafkaImpl
  this.producer = props
  return this
end

function SpringKafka:with_listener_props(props: SpringKafkaListenerProps): SpringKafka
  local this = self::SpringKafkaImpl
  this.listener = props
  return this
end

function SpringKafka:with_retry_props(props: SpringKafkaRetryProps): SpringKafka
  local this = self::SpringKafkaImpl
  this.retry = props
  return this
end

function SpringKafka:with_admin_props(props: SpringKafkaAdminProps): SpringKafka
  local this = self::SpringKafkaImpl
  this.admin = props
  return this
end

function SpringKafka:unwrap(): Unwrapped
  local this = self::SpringKafkaImpl
  return {
    bootstrap_servers = this.bootstrap_servers,
    client_id = this.client_id,
    admin = this.admin,
    consumer = this.consumer,
    listener = this.listener,
    producer = this.producer,
    retry = this.retry,
  }
end

return SpringKafka

