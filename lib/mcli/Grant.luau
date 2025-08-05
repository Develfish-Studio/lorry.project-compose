local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type Grant = {
  policy: string?,
  username: string?,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  policy: string?,
  username: string?,
}

local Grant = {
  policy = nil,
  username = nil,
}

function Grant:new(o): Grant
  return Meta:type(o, self, 'Grant')
end

function Grant:from(username: string, policy: string): Grant
  return Grant:new({
    policy = policy,
    username = username,
  })
end

function Grant.unwrap(self: Grant): Unwrapped
  return {
    policy = self.policy,
    username = self.username,
  }
end

return Grant
