--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Bucket = require('./Bucket')

local Event = {}

export type Event = typeof(Event) & EventProps & Wrapper.Unwrappable<Unwrapped>

export type EventProps = {
  bucket: Bucket.Bucket,
  notify: string,
  events: {string},
}

export type Unwrapped = {
  bucket: Bucket.Unwrapped,
  notify: string,
  events: {string}?,
}

function Event:new(o: EventProps): Event
  return Meta:type(o, self, 'Mcli.Event')
end

function Event:from(bucket: Bucket.Bucket, notify: string): Event
  return Event:new({
    bucket = bucket,
    notify = notify,
    events = Meta:array {},
  })
end

function Event:with_event(event: string): Event
  local this = self::Event
  this.events[#this.events + 1] = event
  return this
end

function Event:with_events(events: {string}): Event
  local this = self::Event
  for _, event in events do
    this.events[#this.events + 1] = event
  end
  return this
end

function Event:unwrap_events(): {string}?
  local this = self::Event
  if #this.events == 0 then
    return nil
  end
  return this.events
end

function Event:unwrap(): Unwrapped
  local this = self::Event
  return {
    bucket = this.bucket,
    notify = this.notify,
    events = this:unwrap_events()
  }
end

return Event
