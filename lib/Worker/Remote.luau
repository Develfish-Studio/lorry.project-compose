--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Remote = {}

export type Remote = typeof(Remote) & RemoteProps & Wrapper.Unwrappable<Unwrapped>

export type RemoteProps = {
  access_key: string,
  secret_key: string,
  server: string,
}

export type Unwrapped = RemoteProps

function Remote:new(o: RemoteProps): Remote
  return Meta:type(o, self, 'Worker.Remote')
end

function Remote:from(server: string, access_key: string, secret_key: string): Remote
  return Remote:new({
    access_key = access_key,
    secret_key = secret_key,
    server = server,
  })
end

function Remote:unwrap(): Unwrapped
  local this = self::Remote
  return {
    access_key = this.access_key,
    secret_key = this.secret_key,
    server = this.server,
  }
end

return Remote
