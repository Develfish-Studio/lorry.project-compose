local Lorry = require('@develfish-repo.utils/lib/Lorry')
local App = require('@root/lib/App')

local variables: App.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  },
}

Lorry.Template:println(Lorry.Yaml:stringify(config))
