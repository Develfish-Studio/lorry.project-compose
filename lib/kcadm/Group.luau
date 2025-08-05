local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type Group = {
  name: string?,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  name: string?,
}

local Group = {
  name = nil,
}

function Group:new(o): Group
  return Meta:type(o, self, 'Group')
end

function Group:from(name: string): Group
  return Group:new({
    name = name,
  })
end

function Group.unwrap(self: Group): Unwrapped
  return {
    name = self.name,
  }
end

return Group
