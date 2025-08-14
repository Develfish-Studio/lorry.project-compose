local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Pgadmin = require('@root/lib/Pgadmin')

local variables: Pgadmin.Unwrapped = Lorry:variables()


local config = {
  Servers = {}
}

for i, server in variables.servers do
  config.Servers[`{i}`] = server
end

Lorry.Template:print(Lorry.Json:stringify(config))
