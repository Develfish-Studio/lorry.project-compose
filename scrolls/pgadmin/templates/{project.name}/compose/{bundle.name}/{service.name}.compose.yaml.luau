local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Pgadmin = require('@root/lib/Pgadmin')

local variables: Pgadmin.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
