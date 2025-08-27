--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local KafkaTarget = {}

export type KafkaTarget = typeof(KafkaTarget) & KafkaTargetProps & Wrapper.Unwrappable<Unwrapped>

export type KafkaTargetProps = {
  name: string?,
  topic: string?,
  brokers: {string},
  events: {[string]: {bucket: string, actions: {string}}},
}

export type Unwrapped = KafkaTargetProps & {
  type: 'KafkaTarget',
}

function KafkaTarget:new(o: KafkaTargetProps): KafkaTarget
  return Meta:type(o, self, 'Mcli.KafkaTarget')
end

function KafkaTarget:from(name: string): KafkaTarget
  return KafkaTarget:new({
    name = name,
    brokers = Meta:array {},
    events = Meta:table {},
  })
end

function KafkaTarget:with_topic(topic: string): KafkaTarget
  local this = self::KafkaTarget
  this.topic = topic
  return this
end

function KafkaTarget:with_broker(broker: string): KafkaTarget
  local this = self::KafkaTarget
  this.brokers[#this.brokers + 1] = broker
  return this
end

function KafkaTarget:with_event(bucket: string, action: string): KafkaTarget
  local this = self::KafkaTarget
  local event = this.events[bucket] or Meta:table {
    bucket = bucket,
    actions = Meta:array {}
  }
  event.actions[#event.actions + 1] = action
  this.events[bucket] = event
  return this
end

function KafkaTarget:unwrap(): Unwrapped
  local this = self::KafkaTarget
  return {
    type = "KafkaTarget" :: "KafkaTarget",
    name = this.name,
    topic = this.topic or this.name,
    brokers = this.brokers,
    events = this.events,
  }
end

return KafkaTarget
