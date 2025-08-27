--!strict

local Meta = require('@lorry.utils/lib/Meta')
local URI = require('@lorry.utils/lib/URI')
local Proxy = require('./Proxy')

local Route = {}

export type Route = typeof(Route)

export type RouteProps = {
  name: string,
  hostname: string,
  port: number,
  path: string,
  redirect: {
    type: string,
    prefix: string?,
    code: number?
  }?,
  proxies: {Proxy.Proxy},
}

export type RouteImpl = Route & RouteProps

export type Unwrapped = {
  name: string,
  hostname: string,
  port: number,
  path: string,
  redirect: {
    type: string,
    prefix: string?,
    code: number?
  }?,
  proxies: {Proxy.Unwrapped},
}

function Route:new(o: RouteProps): Route
  return Meta:type(o, self, 'Haproxy.Route')
end

function Route:from_uri_string(uri_string: string): Route
  local uri = URI:parse(uri_string)
  local hostname = uri.hostname or "localhost"
  local name = hostname:gsub('[\.]', '_'):gsub('[-]', '_')
  return Route:new({
    name = name,
    hostname = hostname,
    port = if uri.port then tonumber(uri.port) else 80,
    path = uri.path or "/",
    redirect = nil,
    proxies = {},
  })
end

function Route:from_arrow(from_uri_string: string, to_uri_string: string): Route
  local route = Route:from_uri_string(from_uri_string)
  local proxy = Proxy:from_uri_string(to_uri_string)
  local res = route:with_proxy(proxy)
  return res
end

function Route:with_name(name: string): Route
  local this = self::RouteImpl
  this.name = name
  return this
end

function Route:with_hostname(hostname: string): Route
  local this = self::RouteImpl
  this.hostname = hostname
  return this
end

function Route:with_port(port: number): Route
  local this = self::RouteImpl
  this.port = port
  return this
end

function Route:with_path(path: string): Route
  local this = self::RouteImpl
  this.path = path
  return this
end

function Route:with_proxy(proxy: Proxy.Proxy): Route
  local this = self::RouteImpl
  this.proxies[#this.proxies + 1] = proxy
  return this
end

function Route:setup(children: {Proxy.Proxy}): Route
  local this = self::RouteImpl
  for i, proxy in children do
    this.proxies[#this.proxies + 1] = proxy
  end
  return this
end

function Route:with_redirect_prefix(prefix: string, code: number?): Route
  local this = self::RouteImpl
  this.redirect = {
    type = 'prefix',
    prefix = prefix,
    code = code or 301
  }
  return this
end

function Route:unwrap(): Unwrapped
  local this = self::RouteImpl
  local proxies = {}
  for i, proxy in this.proxies do
    proxies[i] = proxy:unwrap()
  end
  return {
    name = this.name,
    hostname = this.hostname,
    path = this.path,
    port = this.port,
    redirect = this.redirect,
    proxies = proxies,
  }
end

return Route