--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')

local User = {}

export type User = typeof(User) & UserProps

export type UserProps = {
  email: string?,
  username: string?,
  password: string?,
}

export type Unwrapped = {
  email: string?,
  username: string?,
  password: string?,
}

function User:new(o: UserProps): User
  return Meta:type(o, self, 'Kcadm.User')
end

function User:from_credentials(email: string, password: string): User
  local username = email:match("([^@]*)@(.*)")
  return User:new({
    username = username,
    email = email,
    password = password
  })
end

function User:unwrap(): Unwrapped
  local this = self::User
  return {
    email = this.email,
    username = this.username,
    password = this.password,
  }
end

return User
