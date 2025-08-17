--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local URI = require('@develfish-repo.utils/lib/URI')
local Path = require('@develfish-repo.utils/lib/Path')
local Manifest = require('./Manifest/Manifest')

local Keycloak = {}

export type Keycloak = typeof(Keycloak)

export type KeycloakProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  database: DatabaseData?,
  admin: AdminData?
}

export type DatabaseData = {
  host: string,
  port: string,
  name: string,
  username: string,
  password: string?,
}

export type AdminData = {
  username: string,
  password: string,
}

export type KeycloakImpl = Keycloak & KeycloakProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
    database: DatabaseData?,
    admin: AdminData?,
  }
}

export type Datasource = { url: string, username: string?, password: string? }

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild = Manifest.AnyChild

function Keycloak:new(o: KeycloakProps): Keycloak
  return Meta:type(o, self, 'Keycloak')
end

function Keycloak:from(project: Project.Project, name: string): Keycloak
  assert(project ~= nil)
  assert(name ~= nil)
  return Keycloak
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
    })
end

function Keycloak:configure(configurer: {ConfigurerFunc}): Keycloak
  local this = self::KeycloakImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function Keycloak:setup(children: {AnyChild}): Keycloak
  local this = self::KeycloakImpl
  children = children or Meta:array {}
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Keycloak:with_child(child: AnyChild): Keycloak
  local this = self::KeycloakImpl
  this.manifest:with_child(child::Manifest.AnyChild)
  return this
end

function Keycloak:with_admin(username: string, password: string): Keycloak
  local this = self::KeycloakImpl
  this.admin = {
    username = username,
    password = password,
  }
  return this
end

function Keycloak:with_datasource(datasource: Datasource): Keycloak
  local this = self::KeycloakImpl
  assert(datasource.url ~= nil)
  local uri = URI:parse_jdbc(datasource.url)
  local database = uri.path ~= nil and Path:parse(uri.path):normalize():path() or "keycloak"
  this.database = {
    host = uri.hostname ~= nil and uri.hostname or 'postgres',
    port = uri.port ~= nil and uri.port or '5432',
    name = database,
    username = datasource.username or 'keycloak',
    password = datasource.password,
  }
  return this
end

function Keycloak:unwrap(): Unwrapped
  local this = self::KeycloakImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap(),
      database = this.database,
      admin = this.admin,
    }
  }
end

return Keycloak
