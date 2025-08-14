--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local User = {}

export type User = typeof(User) & UserProps & Wrapper.Unwrappable<Unwrapped>

export type UserProps = {
  username: string,
  password: string,
}

export type Unwrapped = UserProps

function User:new(o: UserProps): User
  return Meta:type(o, self, 'Mcli.User')
end

function User:from(username: string, password: string): User
  return User:new({
    username = username,
    password = password,
  })
end

function User:unwrap(): Unwrapped
  local this = self::User
  return {
    username = this.username,
    password = this.password,
  }
end

return User
