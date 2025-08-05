local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local URI = require('@develfish-repo.utils/lib/URI')
local Proxy = require('@root/lib/haproxy/Proxy')

export type Route = {
  name: string,
  hostname: string,
  port: number,
  path: string,
  redirect: string?,
  proxies: {Proxy.Proxy},

  with_redirect_prefix: (self: Route, prefix: string, code: number?) -> Route,
  with_name: (self: Route, name: string) -> Route,
  with_hostname: (self: Route, hostname: string) -> Route,
  with_port: (self: Route, port: number) -> Route,
  with_path: (self: Route, path: string) -> Route,
  with_proxy: (self: Route, proxy: Proxy.Proxy) -> Route,
  with_proxies: (self: Route, proxies: {Proxy.Proxy}) -> Route,

} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  name: string,
  hostname: string,
  port: number,
  path: string,
  redirect: string?,
  proxies: {Proxy.Unwrapped},
}

local Route = {
  name = 'default',
  hostname = 'localhost',
  port = 80,
  path = '/',
  redirect = nil,
  proxies = {}
}

function Route:new(o): Route
  return Meta:type(o, self, 'Route')
end

function Route:from_uri_string(uri_string: string): Route
  local uri = URI:parse(uri_string)
  local name = uri.hostname:gsub('[\.]', '_'):gsub('[-]', '_')
  return Route:new({
    name = name,
    hostname = uri.hostname,
    port = uri.port,
    path = uri.path,
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
  self.name = name
  return self
end

function Route:with_hostname(hostname: string): Route
  self.hostname = hostname
  return self
end

function Route:with_port(port: number): Route
  self.port = port
  return self
end

function Route:with_path(path: string): Route
  self.path = path
  return self
end

function Route:with_proxy(proxy: Proxy.Proxy): Route
  self.proxies[#self.proxies + 1] = proxy
  return self
end

function Route:with_proxies(proxies: {Proxy.Proxy}): Route
  for i, proxy in proxies do
    self.proxies[#self.proxies + 1] = proxy
  end
  return self
end

function Route:with_redirect_prefix(prefix: string, code: number?): Route
  self.redirect = {
    type = 'prefix',
    prefix = prefix,
    code = code or 301
  }
  return self
end

function Route.unwrap(self: Route): Unwrapped
  local proxies = {}
  for i, proxy in self.proxies do
    proxies[i] = proxy:unwrap()
  end
  return {
    name = self.name,
    hostname = self.hostname,
    path = self.path,
    port = self.port,
    redirect = self.redirect,
    proxies = proxies,
  }
end

return Route