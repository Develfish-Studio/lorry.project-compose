--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')
local Route = require('./Haproxy/Route')
local Proxy = require('./Haproxy/Proxy')
local Server = require('./Haproxy/Server')
local Manifest = require('./Manifest')

local Haproxy = {
  Route = Route,
  Proxy = Proxy,
  Server = Server,
}

export type Haproxy = typeof(Haproxy)

export type HaproxyProps = {
  name: string,
  project: Project.Project,
  routes: {Route.Route},
  manifest: Manifest.Manifest,
}

export type HaproxyImpl = Haproxy & HaproxyProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  routes: {Route.Unwrapped},
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type AnyChild = Route.Route | Manifest.AnyChild

function Haproxy:new(o: HaproxyProps): Haproxy
  return Meta:type(o, self, 'Haproxy')
end

function Haproxy:from(project: Project.Project, name: string): Haproxy
  assert(project ~= nil)
  return Haproxy
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
      routes = Meta:array {},
    })
end

function Haproxy:with_arrow(from_uri_string: string, to_uri_string: string): Haproxy
  local this = self::HaproxyImpl
  self.routes[#self.routes + 1] = Route:from_arrow(from_uri_string, to_uri_string)
  return this
end

function Haproxy:setup(children: {AnyChild}): Haproxy
  local this = self::HaproxyImpl
  children = children or Meta:array {}

  for _, child in children do
    local tag = Meta:typeof(child)
    if tag == 'Haproxy.Route' then
      this.routes[#self.routes + 1] = child::Route.Route
    else
      this.manifest:with_child(child::Manifest.AnyChild)
    end
  end

  return this
end

function Haproxy:unwrap(): Unwrapped
  local this = self::HaproxyImpl
  return {
    project = this.project:unwrap_project(),
    routes = Wrapper:unwrap_array(self.routes),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap(),
    }
  }
end

return Haproxy
