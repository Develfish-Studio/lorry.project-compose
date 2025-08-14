local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Keycloak = require('@root/lib/Keycloak')

local variables: Keycloak.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
