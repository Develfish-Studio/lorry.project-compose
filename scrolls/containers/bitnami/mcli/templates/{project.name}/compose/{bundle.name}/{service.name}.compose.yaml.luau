--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Mcli = require('@root/lib/Mcli/Mcli')
local Remote = require('@root/lib/Mcli/Remote')
local PropTypes = require('@develfish-repo.project/lib/PropTypes')

local variables: Mcli.Unwrapped & PropTypes.WithBundle = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local bundle = Meta:or_object_defaults(variables.bundle, {
  name = 'env'
})

local remote: Remote.Unwrapped = Meta:or_object_defaults(service.remote, {
  access_key = 'admin',
  secret_key = 'admin',
  server = 'http://env-minio:9000',
})

local config = {
  services = {
    [service.name] = {
      image = Meta:or_default(manifest.image, 'bitnami/minio'),
      entrypoint = '/bin/bash /opt/scripts/bootstrap.sh',
      user = 'root',
      restart = 'no',
      deploy = {
        resources = {
          limits = {
            memory = '1G'
          }
        }
      },
      environment = Meta:append(manifest.environment) {
        MINIO_TARGET_SERVER = remote.target_server,
        MINIO_ACCESS_KEY = remote.access_key,
        MINIO_SECRET_KEY = remote.secret_key,
      },
      profiles = manifest.profiles,
      ports = manifest.ports,
      networks = manifest.networks,
      volumes = Meta:or_default(manifest.volumes, {
        `../../config/{bundle.name}/{service.name}/scripts:/opt/scripts`
      }),
      depends_on = manifest.depends_on,
      links = manifest.links
    }
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
