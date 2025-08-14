local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Service = require('@root/lib/Service')

local variables: Service.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
