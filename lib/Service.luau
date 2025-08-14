--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Manifest = require('./Manifest')
local ComposeVolume = require('./Compose/Volume')
local ComposeNetwork = require('./Compose/Network')

local Service = {}

export type Service = typeof(Service)

export type ServiceProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
}

export type ServiceImpl = Service & ServiceProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type AnyChild = Manifest.AnyChild

function Service:new(o: ServiceProps): Service
  return Meta:type(o, self, 'Service')
end

function Service:from(project: Project.Project, name: string): Service
  assert(project ~= nil)
  assert(name ~= nil)
  return Service
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
    })
end

function Service:with_link(service: string, alias: string?): Service
  local this = self::ServiceImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function Service:with_depends_on(service: string): Service
  local this = self::ServiceImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function Service:with_volume_ref(volume: ComposeVolume.Volume, path: string): Service
  local this = self::ServiceImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function Service:with_volume_source(source: string, path: string): Service
  local this = self::ServiceImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function Service:with_network(network: ComposeNetwork.Network): Service
  local this = self::ServiceImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function Service:setup(children: {AnyChild}): Service
  local this = self::ServiceImpl
  children = children or Meta:array {}

  for _, child in children do
    this.manifest:with_child(child)
  end

  return this
end

function Service:unwrap(): Unwrapped
  local this = self::ServiceImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    }
  }
end

return Service