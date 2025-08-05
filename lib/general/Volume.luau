local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type Volume = {
  name: string?,
  path: string?,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  name: string?,
  path: string?,
}

local Volume = {
  name = nil,
  path = nil,
}

function Volume:new(o): Volume
  return Meta:type(o, self, 'Volume')
end

function Volume:from(name: string, path: string): Volume
  return Volume:new({
    name = name,
    path = path,
  })
end

function Volume.unwrap(self: Volume): Unwrapped
  return {
    name = self.name,
    path = self.path,
  }
end

return Volume
