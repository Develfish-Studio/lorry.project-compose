local Meta = require('@develfish-repo.utils/lib/Meta')

export type DependsOn = DependsOnProps

export type DependsOnProps = {
  service: string,
}

local DependsOn = {}

function DependsOn:new(o: DependsOnProps): DependsOn
  return Meta:type(o, self, 'Manifest.DependsOn')
end

function DependsOn:from(service: string): DependsOn
  return DependsOn:new({
    service = service,
  })
end

return DependsOn
