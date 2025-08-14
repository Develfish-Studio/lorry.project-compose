--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')

local Include = {}

export type Include = typeof(Include) & IncludeProps

export type IncludeProps = {
  path: string,
}

function Include:new(o: IncludeProps): Include
  return Meta:type(o, self, 'Compose.Include')
end

function Include:from(path: string): Include
  return Include:new({
    path = path,
  })
end

return Include
