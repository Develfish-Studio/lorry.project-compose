local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Bucket = require('./Bucket')

export type Event = {
  bucket: Bucket.Bucket,
  notify: string,
  events: {string},

  with_event: (self: Event, event: string) -> Event,
  with_events: (self: Event, events: {string}) -> Event,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  bucket: Bucket.Unwrapped,
  notify: string,
  events: {string}?,
}
local Event = {
  bucket = nil,
  notify = nil,
  events = nil,
}

function Event:new(o): Event
  return Meta:type(o, self, 'Event')
end

function Event:from(bucket: string, notify: string): Event
  return Event:new({
    bucket = bucket,
    notify = notify,
    events = Meta:array {},
  })
end

function Event:with_event(event: string): Event
  self.events[#self.events + 1] = event
  return self
end

function Event:with_events(events: {string}): Event
  for _, event in events do
    self.events[#self.events + 1] = event
  end
  return self
end

function Event:unwrap_events(): {string}?
  if #self.events == 0 then
    return nil
  end
  return self.events
end

function Event:unwrap(): Unwrapped
  return {
    bucket = self.bucket,
    notify = self.notify,
    events = self:unwrap_events(),
  }
end

return Event
