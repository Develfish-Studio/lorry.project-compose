local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Worker = require('@root/lib/Worker')

local variables: Worker.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
