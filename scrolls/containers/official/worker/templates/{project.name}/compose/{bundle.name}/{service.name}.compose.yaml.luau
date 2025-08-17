local Meta = require('@develfish-repo.utils/lib/Meta')
local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Worker = require('@root/lib/Worker/Worker')

local variables: Worker.Unwrapped = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local config = {
  services = {
    [service.name] = {
      image = Meta:coalesce(manifest.image, 'alpine:latest'),
      restart ='unless-stopped',
      deploy = {
        resources = {
          limits = {
            memory = '200M'
          }
        }
      },
      environment = manifest.environment,
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
