local Meta = require('@develfish-repo.utils/lib/Meta')

export type EnvVariable = {
  name: string,
  value: string?,
}

local EnvVariable = {}

function EnvVariable:new(o): EnvVariable
  return Meta:type(o, self, 'Manifest.EnvVariable')
end

function EnvVariable:from(name: string, value: string?): EnvVariable
  return EnvVariable:new({
    name = name,
    value = value,
  })
end

return EnvVariable
