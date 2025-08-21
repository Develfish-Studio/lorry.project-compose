--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Haproxy = require('@root/lib/Haproxy/Haproxy')
local PropTypes = require('@root/lib/PropTypes')

local variables: Haproxy.Unwrapped & PropTypes.WithBundle = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local bundle = Meta:or_object_defaults(variables.bundle, {
  name = 'env'
})

local config = {
  services = {
    [service.name] = {
      image = Meta:coalesce(manifest.image, 'nginx:latest'),
      restart ='unless-stopped',
      deploy = {
        resources = {
          limits = {
            cpus = '0.5',
            memory = '200M'
          }
        }
      },
      environment = manifest.environment,
      profiles = manifest.profiles,
      ports = manifest.ports,
      networks = manifest.networks,
      volumes = Meta:or_default(manifest.volumes, {
        `../../config/{bundle.name}/{service.name}:/usr/local/etc/haproxy`
      }),
      depends_on = manifest.depends_on,
      links = manifest.links,
      extra_hosts = {
        "host.docker.internal:host-gateway"
      }
    }
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
