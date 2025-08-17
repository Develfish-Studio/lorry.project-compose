--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Remote = {}

export type Remote = typeof(Remote) & RemoteProps & Wrapper.Unwrappable<Unwrapped>

export type RemoteProps = {
  username: string,
  password: string,
  realm: string,
  server: string,
}

export type Unwrapped = RemoteProps

function Remote:new(o: RemoteProps): Remote
  return Meta:type(o, self, 'Kcadm.Remote')
end

function Remote:from(server: string, realm: string, username: string, password: string): Remote
  return Remote:new({
    username = username,
    password = password,
    realm = realm,
    server = server,
  })
end

function Remote:unwrap(): Unwrapped
  local this = self::Remote
  return {
    username = this.username,
    password = this.password,
    realm = this.realm,
    server = this.server,
  }
end

return Remote
