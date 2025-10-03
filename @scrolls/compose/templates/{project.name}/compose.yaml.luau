local Lorry = require('@lorry.utils/lib/Lorry')
local variables: {[string]: any} = Lorry:variables()

Lorry.Template:print(Lorry.Yaml:stringify(variables.config))
