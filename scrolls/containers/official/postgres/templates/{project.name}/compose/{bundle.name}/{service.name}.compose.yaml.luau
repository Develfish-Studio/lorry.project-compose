local Meta = require('@lorry.utils/lib/Meta')
local Lorry = require('@lorry.utils/lib/Lorry')
local Postgres = require('@root/lib/Postgres/Postgres')
local PropTypes = require('@lorry.project/lib/PropTypes')

local variables: Postgres.Unwrapped & PropTypes.WithBundle = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local bundle = Meta:or_object_defaults(variables.bundle, {
  name = 'env'
})

local config = {
  services = {
    [service.name] = {
      image = Meta:or_default(manifest.image, 'postgres:14'),
      restart ='unless-stopped',
      deploy = {
        resources = {
          limits = {
            memory = '500M'
          }
        }
      },
      environment = Meta:append(manifest.environment) {
        POSTGRES_PASSWORD = 'postgres',
        POSTGRES_USER = 'postgres'
      },
      profiles = manifest.profiles,
      ports = manifest.ports,
      networks = manifest.networks,
      volumes = Meta:or_default(manifest.volumes, {
        `../../config/{bundle.name}/{service.name}/docker-entrypoint-initdb.d/:/docker-entrypoint-initdb.d/`
      }),
      depends_on = manifest.depends_on,
      links = manifest.links
    }
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
