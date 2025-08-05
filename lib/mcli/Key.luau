local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type Key = {
  username: string?,
  access_key: string?,
  secret_key: string?,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  username: string?,
  access_key: string?,
  secret_key: string?,
}

local Key = {
  username = nil,
  access_key = nil,
  secret_key = nil,
}

function Key:new(o): Key
  return Meta:type(o, self, 'Key')
end

function Key:from(username: string, access_key: string, secret_key: string): Key
  return Key:new({
    username = username,
    access_key = access_key,
    secret_key = secret_key,
  })
end

function Key.unwrap(self: Key): Unwrapped
  return {
    username = self.username,
    access_key = self.access_key,
    secret_key = self.secret_key,
  }
end

return Key
