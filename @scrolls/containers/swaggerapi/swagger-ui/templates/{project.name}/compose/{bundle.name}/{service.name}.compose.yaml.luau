--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Lorry = require('@lorry.utils/lib/Lorry')
local Worker = require('@root/lib/Worker/Worker')
local PropTypes = require('@lorry.project/lib/PropTypes')

local variables: Worker.Unwrapped & PropTypes.WithBundle = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local bundle = Meta:or_object_defaults(variables.bundle, {
  name = 'env'
})

local config = {
  services = {
    [service.name] = {
      image = Meta:coalesce(manifest.image, 'swaggerapi/swagger-ui'),
      restart ='unless-stopped',
      deploy = {
        resources = {
          limits = {
            memory = '50M'
          }
        }
      },
      environment = Meta:append(manifest.environment) {
        CONFIG_URL = 'swagger-config.json',
        URL = "",
      },
      profiles = manifest.profiles,
      ports = manifest.ports,
      networks = manifest.networks,
      volumes = Meta:or_default(manifest.volumes, {
        `../../config/{bundle.name}/{service.name}/swagger-config.json:/usr/share/nginx/html/swagger-config.json`
      }),
      depends_on = manifest.depends_on,
      links = manifest.links
    }
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
