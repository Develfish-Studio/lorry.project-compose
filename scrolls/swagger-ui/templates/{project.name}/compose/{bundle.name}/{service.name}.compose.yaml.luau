local Lorry = require('@develfish-repo.utils/lib/Lorry')
local SwaggerUi = require('@root/lib/SwaggerUi')

local variables: SwaggerUi.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
