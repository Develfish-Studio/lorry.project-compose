--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Manifest = require('./Manifest')
local Database = require('./postgres/Database')
local ComposeVolume = require('./compose/Volume')
local ComposeNetwork = require('./compose/Network')

local Postgres = {}

export type Postgres = typeof(Postgres)

export type PostgresProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  databases: {Database.Database},
}

export type PostgresImpl = Postgres & PostgresProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  databases: {Database.Unwrapped},
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type AnyChild = Database.Database | Manifest.AnyChild

function Postgres:new(o: PostgresProps): Postgres
  return Meta:type(o, self, 'Postgres')
end

function Postgres:from(project: Project.Project, name: string): Postgres
  assert(project ~= nil)
  assert(name ~= nil)
  return Postgres
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
      databases = Meta:array {},
    })
end

function Postgres:with_datasource(datasource: Database.Datasource): Postgres
  local this = self::PostgresImpl
  this.databases[#this.databases + 1] = Database:from_datasource(datasource)
  return this
end

function Postgres:with_link(service: string, alias: string?): Postgres
  local this = self::PostgresImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function Postgres:with_depends_on(service: string): Postgres
  local this = self::PostgresImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function Postgres:with_volume_ref(volume: ComposeVolume.Volume, path: string): Postgres
  local this = self::PostgresImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function Postgres:with_volume_source(source: string, path: string): Postgres
  local this = self::PostgresImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function Postgres:with_network(network: ComposeNetwork.Network): Postgres
  local this = self::PostgresImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function Postgres:setup(children: {AnyChild}): Postgres
  local this = self::PostgresImpl
  children = children or Meta:array {}

  for _, child in children do
    local tag = Meta:typeof(child)
    if tag == 'Postgres.Database' then
      this.databases[#self.databases + 1] = child::Database.Database
    else
      this.manifest:with_child(child::Manifest.AnyChild)
    end
  end

  return this
end

function Postgres:unwrap(): Unwrapped
  local this = self::PostgresImpl
  return {
    project = this.project:unwrap_project(),
    databases = Wrapper:unwrap_array(this.databases),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    }
  }
end

return Postgres
