--!strict

local Meta = require('@lorry.utils/lib/Meta')
local URI = require('@lorry.utils/lib/URI')
local Path = require('@lorry.utils/lib/Path')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Server = {}

export type Server = typeof(Server) & ServerProps & Wrapper.Unwrappable<Unwrapped>

export type ServerProps = {
  data: ServerData
}

export type ServerData = {
  Name: string,
  Group: string,
  Port: number,
  Username: string,
  Host: string,
  SSLMode: string,
  MaintenanceDB: string,
}

export type Unwrapped = ServerData

export type Datasource = { url: string, username: string?, password: string? }

function Server:new(o: ServerProps): Server
  return Meta:type(o, self, 'Server')
end

function Server:from_datasource(datasource: Datasource): Server
  assert(datasource.url ~= nil)
  local uri = URI:parse_jdbc(datasource.url)
  local database = uri.path ~= nil and Path:parse(uri.path):normalize():path() or "postgres"
  local data: ServerData = {
    Name = database,
    Group = 'Default',
    Port = uri.port ~= nil and tonumber(uri.port) or 5432,
    Username = datasource.username ~= nil and datasource.username or "postgres",
    Host = uri.hostname ~= nil and uri.hostname or "localhost",
    SSLMode = 'prefer',
    MaintenanceDB = database
  }
  return Server:new({
    data = data
  })
end

function Server:unwrap(): Unwrapped
  local this = self::Server
  return this.data
end

return Server
