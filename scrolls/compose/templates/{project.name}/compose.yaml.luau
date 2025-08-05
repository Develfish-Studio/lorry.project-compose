local Lorry = require('@develfish-repo.utils/lib/Lorry')
local variables: {[string]: any} = Lorry:variables()

Lorry.Template:println(Lorry.Yaml:stringify(variables.config))
