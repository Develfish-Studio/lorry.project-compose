--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Entry = {}

export type Entry = typeof(Entry) & EntryProps & Wrapper.Unwrappable<Unwrapped>

export type EntryProps = {
  name: string,
  url: string,
}

export type Unwrapped = EntryProps

function Entry:new(o: EntryProps): Entry
  return Meta:type(o, self, 'SwaggerUi.Entry')
end

function Entry:from(name: string, url: string): Entry
  return Entry:new({
    name = name,
    url = url
  })
end

function Entry:unwrap(): Unwrapped
  local this = self::Entry
  return {
    name = this.name,
    url = this.url,
  }
end

return Entry
