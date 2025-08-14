local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Postgres = require('@root/lib/Postgres')

local variables: Postgres.Unwrapped = Lorry:variables()

local config = {
  services = {
    [variables.service.name] = variables.service.manifest
  }
}

Lorry.Template:print(Lorry.Yaml:stringify(config))
