--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local URI = require('@develfish-repo.utils/lib/URI')
local Path = require('@develfish-repo.utils/lib/Path')
local Manifest = require('./Manifest')
local ComposeVolume = require('./compose/Volume')
local ComposeNetwork = require('./compose/Network')

local Keycloak = {}

export type Keycloak = typeof(Keycloak)

export type KeycloakProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
}

export type KeycloakImpl = Keycloak & KeycloakProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type Datasource = { uri: string?, username: string?, password: string? }

export type AnyChild = Manifest.AnyChild

function Keycloak:new(o: KeycloakProps): Keycloak
  return Meta:type(o, self, 'Keycloak')
end

function Keycloak:from(project: Project.Project, name: string, datasource: Datasource): Keycloak
  assert(project ~= nil)
  assert(name ~= nil)
  assert(datasource ~= nil)
  return Keycloak
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
    })
end

function Keycloak:with_datasource(datasource: Datasource): Keycloak
  local this = self::KeycloakImpl
  assert(datasource.uri ~= nil)
  local uri = URI:parse_jdbc(datasource.uri)
  local database = Path:parse(uri.path):normalize():path()
  this.manifest
    :with_env_variable('KEYCLOAK_DATABASE_HOST', uri.hostname)
    :with_env_variable('KEYCLOAK_DATABASE_PORT', uri.port)
    :with_env_variable('KEYCLOAK_DATABASE_NAME', database)
    :with_env_variable('KEYCLOAK_DATABASE_USER', datasource.username)
    :with_env_variable('KEYCLOAK_DATABASE_PASSWORD', datasource.password)
  return this
end

function Keycloak:with_link(service: string, alias: string?): Keycloak
  local this = self::KeycloakImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function Keycloak:with_depends_on(service: string): Keycloak
  local this = self::KeycloakImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function Keycloak:with_volume_ref(volume: ComposeVolume.Volume, path: string): Keycloak
  local this = self::KeycloakImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function Keycloak:with_volume_source(source: string, path: string): Keycloak
  local this = self::KeycloakImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function Keycloak:with_network(network: ComposeNetwork.Network): Keycloak
  local this = self::KeycloakImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function Keycloak:setup(children: {AnyChild}): Keycloak
  local this = self::KeycloakImpl
  children = children or Meta:array {}

  for _, child in children do
    this.manifest:with_child(child::Manifest.AnyChild)
  end

  return this
end

function Keycloak:unwrap(): Unwrapped
  local this = self::KeycloakImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    }
  }
end

return Keycloak


-- local Meta = require('@develfish-repo.utils/lib/Meta')
-- local Wrapper = require('@develfish-repo.project/lib/Wrapper')
-- local Project = require('@develfish-repo.project/lib/Project')
-- local Path = require('@develfish-repo.utils/lib/Path')
-- local URI = require('@develfish-repo.utils/lib/URI')

-- export type Keycloak = {
--   project: Project.Project,
--   environment: {[string]: any},
--   depends_on: {string},
--   links: {string},

--   with_datasource: (self: Keycloak, datasource: Datasource) -> Keycloak,
-- } & Wrapper.Unwrappable<Unwrapped>

-- export type Unwrapped = {
--   project: Project.UnwrappedProject,
--   service: {
--     manifest: {
--       environment: {[string]: any},
--       depends_on: {string}?,
--       links: {string}?,
--     }
--   }
-- }

-- type Datasource = { uri: string?, username: string?, password: string? }

-- local Keycloak = {
--   project = nil,
--   environment = nil,
--   depends_on = nil,
--   links = nil,
-- }

-- function Keycloak:new(o): Keycloak
--   return Meta:type(o, self, 'Keycloak')
-- end

-- function Keycloak:from(project: Project.Project, datasource: Datasource): Keycloak
--   assert(project ~= nil)
--   return Keycloak
--     :new({
--       project = project,
--       environment = Meta:table {},
--       depends_on = Meta:array {},
--       links = Meta:array {},
--     })
--     :with_datasource(datasource)
-- end

-- function Keycloak.with_env_variables(self: Keycloak, environment: {[string]: any}): Keycloak
--   environment = environment or Meta:table {}

--   for name, value in environment do
--     self.environment[name] = value
--   end

--   return self
-- end

-- function Keycloak.with_env_variable(self: Keycloak, name: string, value: string): Keycloak
--   self.environment[name] = value
--   return self
-- end

-- function Keycloak.with_datasource(self: Keycloak, datasource: Datasource): Keycloak
--   assert(datasource.uri ~= nil)
--   local uri = URI:parse_jdbc(datasource.uri)
--   local database = Path:parse(uri.path):normalize():path()
--   self.environment.KEYCLOAK_DATABASE_HOST = uri.hostname
--   self.environment.KEYCLOAK_DATABASE_PORT = tonumber(uri.port)
--   self.environment.KEYCLOAK_DATABASE_NAME = database
--   self.environment.KEYCLOAK_DATABASE_USER = datasource.username
--   self.environment.KEYCLOAK_DATABASE_PASSWORD = datasource.password
--   return self
-- end

-- function Keycloak.with_depends_on(self: Keycloak, name: string): Keycloak
--   self.depends_on[#self.depends_on + 1] = name
--   return self
-- end

-- function Keycloak.with_link(self: Keycloak, link: string): Keycloak
--   self.links[#self.links + 1] = link
--   return self
-- end

-- function Keycloak.unwrap(self: Keycloak): Unwrapped
--   return {
--     project = self.project:unwrap_project(),
--     service = {
--       manifest = {
--         environment = self.environment,
--         depends_on = Wrapper:array_or_nil(self.depends_on),
--         links = Wrapper:array_or_nil(self.links),
--       }
--     },
--   }
-- end

-- return Keycloak
