--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Manifest = require('./Manifest')
local ComposeVolume = require('./Compose/Volume')
local ComposeNetwork = require('./Compose/Network')

local Spa = {}

export type Spa = typeof(Spa)

export type SpaImpl = Spa & SpaProps

export type SpaProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

function Spa:new(o: SpaProps): Spa
  return Meta:type(o, self, 'Spa')
end

function Spa:from(project: Project.Project, name: string, image: string): Spa
  assert(project ~= nil)
  assert(image ~= nil)
  return Spa:new({
    project = project,
    name = name,
    image = image,
    manifest = Manifest:from_empty(),
  })
end

function Spa:with_env_variable(name: string, value: string): Spa
  local this = self::SpaImpl
  this.manifest:with_env_variable(name, value)
  return self
end

function Spa:with_env_variables(environment: Manifest.Environment): Spa
  local this = self::SpaImpl
  environment = environment or Meta:table {}
  for name, value in environment do
    this.manifest:with_env_variable(name, value)
  end
  return this
end

function Spa:with_link(service: string, alias: string?): Spa
  local this = self::SpaImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function Spa:with_depends_on(service: string): Spa
  local this = self::SpaImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function Spa:with_volume_ref(volume: ComposeVolume.Volume, path: string): Spa
  local this = self::SpaImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function Spa:with_volume_source(source: string, path: string): Spa
  local this = self::SpaImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function Spa:with_network(network: ComposeNetwork.Network): Spa
  local this = self::SpaImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function Spa:unwrap(): Unwrapped
  local this = self::SpaImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    },
  }
end

return Spa
