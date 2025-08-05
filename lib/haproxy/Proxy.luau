local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Path = require('@develfish-repo.utils/lib/Path')
local Server = require('@root/lib/haproxy/Server')

export type Proxy = {
  path: string,
  cors: string?,
  servers: {},

  with_cors: (self: Proxy, cors: string | boolean | {}) -> Proxy,
  with_server: (self: Proxy, server: Server.Server) -> Proxy,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  path: string,
  cors: {
    origin: string?,
    headers: string?,
    credentials: string?,
    methods: string?,
  }?,
  servers: {Server.Unwrapped},
}

local Proxy = {
  path = nil,
  cors = nil,
  servers = {},
}

function Proxy:new(o): Proxy
  return Meta:type(o, self, 'Proxy')
end

function Proxy:from_path_string(path_string: string): Proxy
  local path = Path:from_string(path_string):normalize()
  return Proxy:new({
    path = path:to_string(),
    servers = {},
  })
end

function Proxy:from_uri_string(uri_string: string): Proxy
  local server = Server:from_uri_string(uri_string)
  return Proxy:from_path_string('/'):with_server(server)
end

function Proxy:with_cors(cors): Proxy
  if type(cors) == 'string' then
    self.cors = { origin = cors }
  elseif type(cors) == 'boolean' and cors then
    self.cors = {}
  elseif type(cors) == 'table' then
    self.cors.origin = cors.origin or '*'
    self.cors.headers = cors.headers or '*'
    self.cors.credentials = cors.credentials or 'true'
    self.cors.methods = cors.methods or 'GET, DELETE, OPTIONS, POST, PUT, PATCH'
  end
  return self
end

function Proxy:with_server(server: Server.Server): Proxy
  self.servers[#self.servers + 1] = server
  return self
end

function Proxy:unwrap(): Unwrapped
  local servers = {}
  for i, server in self.servers do
    servers[i] = server:unwrap()
  end
  return {
    path = self.path,
    cors = self.cors,
    servers = servers
  }
end

return Proxy
