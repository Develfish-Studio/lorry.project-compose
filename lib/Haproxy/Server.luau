--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local URI = require('@develfish-repo.utils/lib/URI')

local Server = {}

export type Server = typeof(Server) & Wrapper.Unwrappable<Unwrapped>

export type CheckData = {
  port: number?,
}

export type ServerProps = {
  hostname: string?,
  port: number?,
  optional: boolean?,
  backup: boolean?,
  check: CheckData?,
}

export type ServerImpl = Server & ServerProps

export type Unwrapped = {
  hostname: string?,
  port: number?,
  optional: boolean?,
  backup: boolean?,
  check: CheckData?,
}

function Server:new(o: ServerProps): Server
  return Meta:type(o, self, 'Haproxy.Server')
end

function Server:from_uri_string(uri_string: string): Server
  local uri = URI:parse(uri_string)
  local port = tonumber(uri.port)
  return Server:new({
    hostname = uri.hostname,
    port = port,
    check = {},
  })
end

function Server:with_check(check: number | string | boolean | CheckData): Server
  local this = self::ServerImpl
  if type(check) == 'number' then
    this.check = { port = check::number }
  elseif type(check) == 'string' then
    this.check = { port = tonumber(check)::number }
  elseif type(check) == 'boolean' then
    if check then
      this.check = {}
    else
      this.check = nil
    end
  elseif type(check) == 'table' then
    this.check = {
      port = check.port
    }
  end
  return this
end

function Server:with_optional(optional: boolean): Server
  local this = self::ServerImpl
  this.optional = optional
  return this
end

function Server:with_backup(backup: boolean): Server
  local this = self::ServerImpl
  this.backup = backup
  return this
end

function Server:unwrap(): Unwrapped
  local this = self::ServerImpl
  return {
    hostname = this.hostname,
    port = this.port,
    check = this.check,
    optional = this.optional,
    backup = this.backup,
  }
end

return Server
