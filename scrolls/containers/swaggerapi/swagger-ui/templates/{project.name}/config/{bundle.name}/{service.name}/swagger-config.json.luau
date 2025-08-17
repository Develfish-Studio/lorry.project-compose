local Lorry = require('@develfish-repo.utils/lib/Lorry')
local SwaggerUi = require('@root/lib/SwaggerUi/SwaggerUi')

local variables: SwaggerUi.Unwrapped = Lorry:variables()

Lorry.Template:print(Lorry.Json:stringify(variables.config))
