local Meta = require('@develfish-repo.utils/lib/Meta')
local Path = require('@develfish-repo.utils/lib/Path')
local URI = require('@develfish-repo.utils/lib/URI')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type Manifest = {
  environment: {[string]: string?},

  with_datasource: (self: Manifest, datasource: {}) -> Manifest,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  environment: {[string]: string?},
}

local Manifest = {
  environment = {},
}

function Manifest:new(o): Manifest
  return Meta:type(o, self, 'Manifest')
end

function Manifest:from_datasource(datasource: {[string]: any?}): Manifest
  return Manifest
    :new({ environment = {} })
    :with_datasource(datasource)
end

function Manifest.with_datasource(self: Manifest, datasource: {[string]: any?}): Manifest
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

function Manifest:unwrap(): Unwrapped
  return {
    environment = self.environment,
  }
end

return Manifest
