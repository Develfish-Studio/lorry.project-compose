--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local PropTypes = require('@lorry.project/lib/PropTypes')

local Remote = {}

export type Remote = typeof(Remote) & RemoteProps & Wrapper.Unwrappable<Unwrapped>

export type RemoteProps = PropTypes.MinioRemote

export type Unwrapped = RemoteProps

function Remote:new(o: RemoteProps): Remote
  return Meta:type(o, self, 'Mcli.Remote')
end

function Remote:from(target_server: string, access_key: string, secret_key: string): Remote
  return Remote:new({
    access_key = access_key,
    secret_key = secret_key,
    target_server = target_server,
  })
end

function Remote:unwrap(): Unwrapped
  local this = self::Remote
  return {
    access_key = this.access_key,
    secret_key = this.secret_key,
    target_server = this.target_server,
  }
end

return Remote
