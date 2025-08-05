local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type Realm = {
  name: string?
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  name: string?
}

local Realm = {
  name = nil,
}

function Realm:new(o): Realm
  return Meta:type(o, self, 'Realm')
end

function Realm:from(name: string): Realm
  return Realm:new({
    name = name,
  })
end

function Realm:unwrap(): Unwrapped
  return {
    name = self.name,
  }
end

return Realm
