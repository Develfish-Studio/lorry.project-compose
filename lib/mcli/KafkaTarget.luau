local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type KafkaTarget = {
  name: string?,
  topic: string?,
  brokers: {string},
  events: {[string]: {bucket: string, actions: {string}}},

  with_topic: (self: KafkaTarget, topic: string) -> KafkaTarget,
  with_broker: (self: KafkaTarget, broker: string) -> KafkaTarget,
  with_event: (self: KafkaTarget, bucket: string, action: string) -> KafkaTarget

} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  type: 'KafkaTarget',
  name: string?,
  topic: string?,
  brokers: {string},
  events: {[string]: {bucket: string, actions: {string}}},
}

local KafkaTarget = {
  name = nil,
  topic = nil,
  brokers = nil,
  events = nil,
}

function KafkaTarget:new(o): KafkaTarget
  return Meta:type(o, self, 'KafkaTarget')
end

function KafkaTarget:from(name: string): KafkaTarget
  return KafkaTarget:new({
    name = name,
    brokers = Meta:array {},
    events = Meta:table {},
  })
end

function KafkaTarget.with_topic(self: KafkaTarget, topic: string): KafkaTarget
  self.topic = topic
  return self
end

function KafkaTarget.with_broker(self: KafkaTarget, broker: string): KafkaTarget
  self.brokers[#self.brokers + 1] = broker
  return self
end

function KafkaTarget.with_event(self: KafkaTarget, bucket: string, action: string): KafkaTarget
  local event = self.events[bucket] or Meta:table {
    bucket = bucket,
    actions = Meta:array {}
  }
  event.actions[#event.actions + 1] = action
  self.events[bucket] = event
  return self
end

function KafkaTarget.unwrap(self: KafkaTarget): Unwrapped
  return {
    type = 'KafkaTarget',
    name = self.name,
    topic = self.topic or self.name,
    brokers = self.brokers,
    events = self.events,
  }
end

return KafkaTarget
