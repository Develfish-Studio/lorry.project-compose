--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Lorry = require('@lorry.utils/lib/Lorry')
local Kcadm = require('@root/lib/Kcadm/Kcadm')
local Remote = require('@root/lib/Kcadm/Remote')
local PropTypes = require('@lorry.project/lib/PropTypes')

local variables: Kcadm.Unwrapped & PropTypes.WithBundle = Lorry:variables()
local service = variables.service
local manifest = service.manifest

local bundle = Meta:or_object_defaults(variables.bundle, {
  name = 'env'
})

local remote: Remote.Unwrapped = Meta:or_object_defaults(service.remote, {
  username = 'admin',
  password = 'admin',
  realm = 'master',
  server = 'http://env-keycloak:8080/auth',
})

local config = {
  services = {
    [service.name] = {
      image = Meta:or_default(manifest.image, 'bitnami/keycloak:latest'),
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
        KEYCLOAK_ADMIN = remote.username,
        KEYCLOAK_ADMIN_PASSWORD = remote.password,
        KEYCLOAK_ADMIN_REALM = remote.realm,
        KEYCLOAK_TARGET_SERVER = remote.server,
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
