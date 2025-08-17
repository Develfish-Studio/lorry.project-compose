--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Server = require('./Server')
local Manifest = require('../Manifest/Manifest')

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
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
    servers: {Server.Unwrapped}?,
  }
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild =
  | Server.Server
  | Manifest.AnyChild

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

function Pgadmin:configure(configurer: {ConfigurerFunc}): Pgadmin
  local this = self::PgadminImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function Pgadmin:setup(children: {AnyChild}): Pgadmin
  local this = self::PgadminImpl
  children = children or Meta:array {}
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Pgadmin:with_child(child: AnyChild): Pgadmin
  local this = self::PgadminImpl
  local tag = Meta:typeof(child)
  if tag == 'Pgadmin.Server' then
    this.servers[#this.servers + 1] = child::Server.Server
  else
    this.manifest:with_child(child::Manifest.AnyChild)
  end
  return this
end

function Pgadmin:with_datasource(datasource: Server.Datasource): Pgadmin
  local this = self::PgadminImpl
  this.servers[#this.servers + 1] = Server:from_datasource(datasource)
  return this
end

function Pgadmin:unwrap(): Unwrapped
  local this = self::PgadminImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      servers = Wrapper:unwrap_array_or_nil(this.servers),
      manifest = this.manifest:unwrap()
    }
  }
end

return Pgadmin
