--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Key = {}

export type Key = typeof(Key) & KeyProps & Wrapper.Unwrappable<Unwrapped>

export type KeyProps = {
  username: string,
  access_key: string,
  secret_key: string,
}

export type Unwrapped = KeyProps

function Key:new(o: KeyProps): Key
  return Meta:type(o, self, 'Mcli.Key')
end

function Key:from(username: string, access_key: string, secret_key: string): Key
  return Key:new({
    username = username,
    access_key = access_key,
    secret_key = secret_key,
  })
end

function Key:unwrap(): Unwrapped
  local this = self::Key
  return {
    username = this.username,
    access_key = this.access_key,
    secret_key = this.secret_key,
  }
end

return Key
