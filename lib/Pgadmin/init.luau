--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Manifest = require('./Manifest')
local Server = require('./Pgadmin/Server')
local ComposeVolume = require('./Compose/Volume')
local ComposeNetwork = require('./Compose/Network')

local Pgadmin = {}

export type Pgadmin = typeof(Pgadmin)

export type PgadminProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  servers: {Server.Server},
}

export type PgadminImpl = Pgadmin & PgadminProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  servers: {Server.Unwrapped},
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type AnyChild = Server.Server | Manifest.AnyChild

function Pgadmin:new(o: PgadminProps): Pgadmin
  return Meta:type(o, self, 'Pgadmin')
end

function Pgadmin:from(project: Project.Project, name: string): Pgadmin
  assert(project ~= nil)
  assert(name ~= nil)
  return Pgadmin
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
      servers = Meta:array {},
    })
end

function Pgadmin:with_datasource(datasource: Server.Datasource): Pgadmin
  local this = self::PgadminImpl
  this.servers[#this.servers + 1] = Server:from_datasource(datasource)
  return this
end

function Pgadmin:with_link(service: string, alias: string?): Pgadmin
  local this = self::PgadminImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function Pgadmin:with_depends_on(service: string): Pgadmin
  local this = self::PgadminImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function Pgadmin:with_volume_ref(volume: ComposeVolume.Volume, path: string): Pgadmin
  local this = self::PgadminImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function Pgadmin:with_volume_source(source: string, path: string): Pgadmin
  local this = self::PgadminImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function Pgadmin:with_network(network: ComposeNetwork.Network): Pgadmin
  local this = self::PgadminImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function Pgadmin:setup(children: {AnyChild}): Pgadmin
  local this = self::PgadminImpl
  children = children or Meta:array {}

  for _, child in children do
    local tag = Meta:typeof(child)
    if tag == 'Pgadmin.Server' then
      this.servers[#self.servers + 1] = child::Server.Server
    else
      this.manifest:with_child(child::Manifest.AnyChild)
    end
  end

  return this
end

function Pgadmin:unwrap(): Unwrapped
  local this = self::PgadminImpl
  return {
    project = this.project:unwrap_project(),
    servers = Wrapper:unwrap_array(self.servers),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    }
  }
end

return Pgadmin
