local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Haproxy = require('@root/lib/Haproxy')

local variables: Haproxy.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
