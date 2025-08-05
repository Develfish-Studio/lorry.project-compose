local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local URI = require('@develfish-repo.utils/lib/URI')

export type Server = {
  hostname: string?,
  port: number?,
  optional: boolean?,
  backup: boolean?,
  check: {
    port: number?,
  }?,

  with_optional: (self: Server, optional: boolean) -> Server,
  with_backup: (self: Server, backup: boolean) -> Server,
  with_check: (self: Server, check: number | string | boolean | {port: number}) -> Server,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  hostname: string?,
  port: number?,
  optional: boolean?,
  backup: boolean?,
  check: {
    port: number?,
  }?,
}

local Server = {
  hostname = nil,
  port = nil,
  optional = false,
  backup = false,
  check = true,
}

function Server:new(o): Server
  return Meta:type(o, self, 'Server')
end

function Server:from_uri_string(uri_string: string): Server
  local uri = URI:parse(uri_string)
  local port = tonumber(uri.port)
  return Server:new({
    hostname = uri.hostname,
    port = port,
  })
end

function Server:with_check(check: number | string | boolean | {port: number}): Server
  if type(check) == 'number' then
    self.check = { port = check::number }
  elseif type(check) == 'string' then
    self.check = { port = tonumber(check)::number }
  elseif type(check) == 'boolean' then
    if check then
      self.check = {}
    else
      self.check = nil
    end
  elseif type(check) == 'table' then
    self.check = {
      port = check.port
    }
  end
  return self
end

function Server.with_optional(self: Server, optional: boolean): Server
  self.optional = optional
  return self
end

function Server.with_backup(self: Server, backup: boolean): Server
  self.backup = backup
  return self
end

function Server.unwrap(self: Server): Unwrapped
  return {
    hostname = self.hostname,
    port = self.port,
    check = self.check,
    optional = self.optional,
    backup = self.backup,
  }
end

return Server
