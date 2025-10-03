--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Lorry = require('@lorry.utils/lib/Lorry')
local Keycloak = require('@root/lib/Keycloak')

local variables: Keycloak.Unwrapped = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local database: Keycloak.DatabaseData = Meta:apply_object_defaults(service.database) {
  host = 'postgres',
  port = '5432',
  username = 'keycloak',
  name = 'keycloak',
}

local admin: Keycloak.AdminData = Meta:apply_object_defaults(service.admin) {
  username = 'admin',
  password = 'admin',
}

local config = {
  services = {
    [service.name] = {
      image = Meta:coalesce(manifest.image, 'bitnami/keycloak:latest'),
      restart ='unless-stopped',
      deploy = {
        resources = {
          limits = {
            memory = '1G'
          }
        }
      },
      environment = Meta:append(manifest.environment) {
        KEYCLOAK_ADMIN = admin.username,
        KEYCLOAK_ADMIN_PASSWORD = admin.password,
        KEYCLOAK_CACHE_TYPE = 'local',
        KEYCLOAK_DATABASE_HOST = database.host,
        KEYCLOAK_DATABASE_NAME = database.name,
        KEYCLOAK_DATABASE_PASSWORD = database.password,
        KEYCLOAK_DATABASE_PORT = database.port,
        KEYCLOAK_DATABASE_USER = database.username,
        KEYCLOAK_ENABLE_HTTPS = 'false',
        KEYCLOAK_ENABLE_STATISTICS = 'false',
        KEYCLOAK_HTTP_PORT = '8080',
        KEYCLOAK_HTTP_RELATIVE_PATH = '/auth/',
        KEYCLOAK_LOG_OUTPUT = 'default',
        KEYCLOAK_PRODUCTION = 'false',
        KEYCLOAK_PROXY = 'passthrough',
        PROXY_ADDRESS_FORWARDING = 'true',
      },
      profiles = manifest.profiles,
      ports = manifest.ports,
      networks = manifest.networks,
      volumes = manifest.volumes,
      depends_on = manifest.depends_on,
      links = manifest.links
    }
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
