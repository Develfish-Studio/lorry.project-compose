--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Client = {}

export type Client = typeof(Client) & ClientProps & Wrapper.Unwrappable<Unwrapped>

export type ClientProps = {
  name: string?,
  secret: string?,
}

export type Unwrapped = {
  name: string?,
  secret: string?,
}

function Client:new(o: ClientProps): Client
  return Meta:type(o, self, 'Kcadm.Client')
end

function Client:from(name: string, secret: string): Client
  return Client:new({
    name = name,
    secret = secret,
  })
end

function Client:unwrap(): Unwrapped
  local this = self::Client
  return {
    name = this.name,
    secret = this.secret,
  }
end

return Client
