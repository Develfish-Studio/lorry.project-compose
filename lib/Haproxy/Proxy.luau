--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Path = require('@develfish-repo.utils/lib/Path')
local Server = require('./Server')

local Proxy = {}

export type Proxy = typeof(Proxy)

export type ProxyProps = {
  path: string,
  cors: {
    origin: string?,
    headers: string?,
    credentials: string?,
    methods: string?,
  }?,
  servers: {Server.Server},
}

export type ProxyImpl = Proxy & ProxyProps

export type CorsData = {
  origin: string?,
  headers: string?,
  credentials: string?,
  methods: string?,
}

export type Unwrapped = {
  path: string,
  cors: CorsData?,
  servers: {Server.Unwrapped},
}

function Proxy:new(o: ProxyProps): Proxy
  return Meta:type(o, self, 'Haproxy.Proxy')
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
  return Proxy:from_path_string('/'):setup({server})
end

function Proxy:with_cors(cors: string | boolean | CorsData): Proxy
  local this = self::ProxyImpl
  if type(cors) == 'string' then
    this.cors = { origin = cors }
  elseif type(cors) == 'boolean' and cors then
    this.cors = {}
  elseif type(cors) == 'table' then
    this.cors = cors
  end
  return this
end

function Proxy:with_server(uri_string: string): Proxy
  local this = self::ProxyImpl
  this.servers[#this.servers + 1] = Server:from_uri_string(uri_string)
  return this
end

function Proxy:with_optional_server(uri_string: string): Proxy
  local this = self::ProxyImpl
  this.servers[#this.servers + 1] = Server:from_uri_string(uri_string):with_optional(true)
  return this
end

function Proxy:with_optional_backup_server(uri_string: string): Proxy
  local this = self::ProxyImpl
  this.servers[#this.servers + 1] = Server:from_uri_string(uri_string):with_optional(true):with_backup(true)
  return this
end

function Proxy:with_required_server(uri_string: string): Proxy
  local this = self::ProxyImpl
  this.servers[#this.servers + 1] = Server:from_uri_string(uri_string):with_optional(false)
  return this
end

function Proxy:setup(children: {Server.Server}): Proxy
  local this = self::ProxyImpl
  children = children or Meta:array {}
  for _, child in children do
    local tag = Meta:typeof(child)
    if tag == 'Haproxy.Server' then
      this.servers[#this.servers + 1] = child::Server.Server
    end
  end
  return self
end

function Proxy:unwrap(): Unwrapped
  local this = self::ProxyImpl
  local servers = {}
  for i, server in this.servers do
    servers[i] = server:unwrap()
  end
  return {
    path = this.path,
    cors = this.cors,
    servers = Wrapper:unwrap_array(this.servers)
  }
end

return Proxy
