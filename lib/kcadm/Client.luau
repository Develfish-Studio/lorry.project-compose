local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type Client = {
  name: string?,
  secret: string?,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  name: string?,
  secret: string?,
}

local Client = {
  name = nil,
  secret = nil,
}

function Client:new(o): Client
  return Meta:type(o, self, 'Client')
end

function Client:from(name: string, secret: string): Client
  return Client:new({
    name = name,
    secret = secret,
  })
end

function Client.unwrap(self: Client): Unwrapped
  return {
    name = self.name,
    secret = self.secret,
  }
end

return Client
