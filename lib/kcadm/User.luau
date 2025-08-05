local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

export type User = {
  email: string?,
  username: string?,
  password: string?,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  email: string?,
  username: string?,
  password: string?,
}

local User = {
  email = nil,
  username = nil,
  password = nil,
}

function User:new(o): User
  return Meta:type(o, self, 'User')
end

function User:from_credentials(email: string, password: string): User
  local username = email:match("([^@]*)@(.*)")
  return User:new({
    username = username,
    email = email,
    password = password
  })
end

function User.unwrap(self: User): Unwrapped
  return {
    email = self.email,
    username = self.username,
    password = self.password,
  }
end

return User
