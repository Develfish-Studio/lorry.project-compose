local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')
local Route = require('@root/lib/haproxy/Route')
local Proxy = require('@root/lib/haproxy/Proxy')
local Server = require('@root/lib/haproxy/Server')

export type Haproxy = {
  project: Project.Project,
  routes: {Route.Route},

  with_rules: (self: Haproxy, children: {any}) -> Haproxy,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  project: Project.UnwrappedProject,
  routes: {Route.Unwrapped},
}

local Haproxy = {
  Route = Route,
  Proxy = Proxy,
  Server = Server,

  project = nil,
  routes = nil,
}

function Haproxy:new(o): Haproxy
  return Meta:type(o, self, 'Haproxy')
end

function Haproxy:from(project: Project.Project): Haproxy
  assert(project ~= nil)
  return Haproxy
    :new({
      project = project,
      routes = Meta:array {},
    })
end

function Haproxy.with_rules(self: Haproxy, children: {any}): Haproxy
  children = children or Meta:array {}

  for _, child in children do
    if child.__type == 'Route' then
      self.routes[#self.routes + 1] = child::Route.Route
    end
  end

  return self
end

function Haproxy.unwrap(self: Haproxy): Unwrapped
  return {
    project = self.project:unwrap_project(),
    routes = Wrapper:unwrap_array(self.routes),
  }
end

return Haproxy
