local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Mcli = require('@root/lib/Mcli')

local variables: Mcli.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
