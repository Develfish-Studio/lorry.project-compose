--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Project = require('@lorry.project/lib/Project')
local Include = require('./Include')
local Network = require('./Network')
local Volume = require('./Volume')

local Compose = {
  Include = Include,
  Network = Network,
  Volume = Volume,
}

export type Compose = typeof(Compose)

export type ComposeProps = {
  project: Project.Project,
  include: {Include.Include},
  networks: {Network.Network},
  volumes: {Volume.Volume},
}

export type ComposeImpl = Compose & ComposeProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  config: {
    include: {{path: string}},
    networks: {[string]: Network.NetworkData},
    volumes: {[string]: Volume.VolumeData}
  }
}
export type AnyChild = Include.Include | Network.Network | Volume.Volume

function Compose:new(o: ComposeProps): Compose
  return Meta:type(o, self, 'Compose')
end

function Compose:from(project: Project.Project): Compose
  assert(project ~= nil)
  return Compose:new({
    project = project,
    include = Meta:array {},
    networks = Meta:array {},
    volumes = Meta:array {},
  })
end

function Compose:setup(children: {AnyChild}): Compose
  local this = self::ComposeImpl
  children = children or Meta:array {}
  for _, child in children do
    local type_name = Meta:typeof(child)
    if type_name == 'Compose.Include' then
      this.include[#this.include + 1] = child::Include.Include
    elseif type_name == 'Compose.Network' then
      this.networks[#this.networks + 1] = child::Network.Network
    elseif type_name == 'Compose.Volume' then
      this.volumes[#this.volumes + 1] = child::Volume.Volume
    end
  end
  return this
end

function Compose:with_include(path: string): Compose
  local this = self::ComposeImpl
  this.include[#this.include + 1] = Include:from(path)
  return self
end

function Compose:with_network(name: string): Compose
  local this = self::ComposeImpl
  this.networks[#this.networks + 1] = Network:from(name)
  return self
end

function Compose:unwrap(): Unwrapped
  local this = self::ComposeImpl
  return {
    project = this.project:unwrap_project(),
    config = {
      include = Wrapper:map(this.include, function (n) return { path = n.path } end),
      networks = Wrapper:associate_by_prop(this.networks, 'name', function (n) return n.data end),
      volumes = Wrapper:associate_by_prop(this.volumes, 'name', function (v) return v.data end),
    },
  }
end

return Compose
