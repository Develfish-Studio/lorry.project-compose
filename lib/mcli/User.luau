local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type User = {
  username: string?,
  password: string?,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  username: string?,
  password: string?,
}

local User = {
  username = nil,
  password = nil,
}

function User:new(o): User
  return Meta:type(o, self, 'User')
end

function User:from(username: string, password: string): User
  return User:new({
    username = username,
    password = password,
  })
end

function User.unwrap(self: User): Unwrapped
  return {
    username = self.username,
    password = self.password,
  }
end

return User
