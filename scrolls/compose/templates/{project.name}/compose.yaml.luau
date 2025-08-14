local Lorry = require('@develfish-repo.utils/lib/Lorry')
local variables: {[string]: any} = Lorry:variables()

Lorry.Template:print(Lorry.Yaml:stringify(variables.config))
