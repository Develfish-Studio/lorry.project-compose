--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Database = require('./Database')
local Manifest = require('../Manifest/Manifest')

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
  service: {
    name: string,
    databases: {Database.Unwrapped}?,
    manifest: Manifest.Unwrapped,
  }
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild =
  | Database.Database
  | Manifest.AnyChild

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

function Postgres:configure(configurer: {ConfigurerFunc}): Postgres
  local this = self::PostgresImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function Postgres:setup(children: {AnyChild}): Postgres
  local this = self::PostgresImpl
  children = children or Meta:array {}
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Postgres:with_child(child: AnyChild): Postgres
  local this = self::PostgresImpl
  local tag = Meta:typeof(child)
  if tag == 'Postgres.Database' then
    this.databases[#this.databases + 1] = child::Database.Database
  else
    this.manifest:with_child(child::Manifest.AnyChild)
  end
  return this
end

function Postgres:with_datasource(datasource: Database.Datasource): Postgres
  local this = self::PostgresImpl
  this.databases[#this.databases + 1] = Database:from_datasource(datasource)
  return this
end

function Postgres:unwrap(): Unwrapped
  local this = self::PostgresImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      databases = Wrapper:unwrap_array_or_nil(this.databases),
      manifest = this.manifest:unwrap()
    }
  }
end

return Postgres
