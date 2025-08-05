local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')
local Path = require('@develfish-repo.utils/lib/Path')
local URI = require('@develfish-repo.utils/lib/URI')

export type Keycloak = {
  project: Project.Project,
  environment: {[string]: any},
  depends_on: {string},
  links: {string},

  with_datasource: (self: Keycloak, datasource: Datasource) -> Keycloak,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    manifest: {
      environment: {[string]: any},
      depends_on: {string}?,
      links: {string}?,
    }
  }
}

type Datasource = { uri: string?, username: string?, password: string? }

local Keycloak = {
  project = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
}

function Keycloak:new(o): Keycloak
  return Meta:type(o, self, 'Keycloak')
end

function Keycloak:from(project: Project.Project, datasource: Datasource): Keycloak
  assert(project ~= nil)
  return Keycloak
    :new({
      project = project,
      environment = Meta:table {},
      depends_on = Meta:array {},
      links = Meta:array {},
    })
    :with_datasource(datasource)
end

function Keycloak.with_env_variables(self: Keycloak, environment: {[string]: any}): Keycloak
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Keycloak.with_env_variable(self: Keycloak, name: string, value: string): Keycloak
  self.environment[name] = value
  return self
end

function Keycloak.with_datasource(self: Keycloak, datasource: Datasource): Keycloak
  assert(datasource.uri ~= nil)
  local uri = URI:parse_jdbc(datasource.uri)
  local database = Path:parse(uri.path):normalize():path()
  self.environment.KEYCLOAK_DATABASE_HOST = uri.hostname
  self.environment.KEYCLOAK_DATABASE_PORT = tonumber(uri.port)
  self.environment.KEYCLOAK_DATABASE_NAME = database
  self.environment.KEYCLOAK_DATABASE_USER = datasource.username
  self.environment.KEYCLOAK_DATABASE_PASSWORD = datasource.password
  return self
end

function Keycloak.with_depends_on(self: Keycloak, name: string): Keycloak
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function Keycloak.with_link(self: Keycloak, link: string): Keycloak
  self.links[#self.links + 1] = link
  return self
end

function Keycloak.unwrap(self: Keycloak): Unwrapped
  return {
    project = self.project:unwrap_project(),
    service = {
      manifest = {
        environment = self.environment,
        depends_on = Wrapper:array_or_nil(self.depends_on),
        links = Wrapper:array_or_nil(self.links),
      }
    },
  }
end

return Keycloak
