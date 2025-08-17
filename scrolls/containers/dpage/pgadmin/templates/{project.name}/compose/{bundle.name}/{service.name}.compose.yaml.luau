local Meta = require('@develfish-repo.utils/lib/Meta')
local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Pgadmin = require('@root/lib/Pgadmin/Pgadmin')
local PropTypes = require('@root/lib/PropTypes')

local variables: Pgadmin.Unwrapped & PropTypes.WithBundle = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local bundle = Meta:or_object_defaults(variables.bundle, {
  name = 'env'
})

-- todo: Add 'user' property to Pgadmin struct

local config = {
  services = {
    [service.name] = {
      image = Meta:coalesce(manifest.image, 'dpage/pgadmin4'),
      restart ='unless-stopped',
      deploy = {
        resources = {
          limits = {
            memory = '500M'
          }
        }
      },
      environment = Meta:append(manifest.environment) {
        PGADMIN_DEFAULT_EMAIL = 'admin@example.com',
        PGADMIN_DEFAULT_PASSWORD = 'admin'
      },
      profiles = manifest.profiles,
      ports = manifest.ports,
      networks = manifest.networks,
      volumes = Meta:or_default(manifest.volumes, {
        `../../config/{bundle.name}/{service.name}/servers.json:/pgadmin4/servers.json`
      }),
      depends_on = manifest.depends_on,
      links = manifest.links
    }
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
