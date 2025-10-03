--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Lorry = require('@lorry.utils/lib/Lorry')
local Minio = require('@root/lib/Minio/Minio')

local variables: Minio.Unwrapped = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local admin: Minio.AdminData = Meta:apply_object_defaults(service.admin) {
  username = 'admin',
  password = 'admin',
}

local config = {
  services = {
    [service.name] = {
      image = Meta:or_default(manifest.image, 'bitnami/minio'),
      restart = 'unless-stopped',
      deploy = {
        resources = {
          limits = {
            memory = '500M'
          }
        }
      },
      environment = Meta:append(manifest.environment) {
        MINIO_ROOT_USER = admin.username,
        MINIO_ROOT_PASSWORD = admin.password,
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
