local Meta = require('@develfish-repo.utils/lib/Meta')
local Lorry = require('@develfish-repo.utils/lib/Lorry')
local Pgadmin = require('@root/lib/Pgadmin/Pgadmin')

local variables: Pgadmin.Unwrapped = Lorry:variables()

local config = {
  Servers = Meta:table {}
}

if variables.service.servers ~= nil then
  for i, server in variables.service.servers do
    config.Servers[`{i}`] = server
  end
end

Lorry.Template:print(Lorry.Json:stringify(config))
