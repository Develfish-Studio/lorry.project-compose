local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Spa = require('@root/lib/Spa')

local variables: Spa.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
