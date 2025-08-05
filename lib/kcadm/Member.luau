local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type Member = {
  username: string?,
  group: string?,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  username: string?,
  group: string?,
}

local Member = {
  username = nil,
  group = nil
}

function Member:new(o): Member
  return Meta:type(o, self, 'Member')
end

function Member:from(username: string, group: string): Member
  return Member:new({
    username = username,
    group = group
  })
end

function Member.unwrap(self: Member): Unwrapped
  return {
    username = self.username,
    group = self.group
  }
end

return Member
