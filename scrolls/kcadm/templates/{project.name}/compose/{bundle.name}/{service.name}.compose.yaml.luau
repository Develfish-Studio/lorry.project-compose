local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Kcadm = require('@root/lib/Kcadm')

local variables: Kcadm.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
