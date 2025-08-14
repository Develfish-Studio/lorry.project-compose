--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Grant = {}

export type Grant = typeof(Grant) & GrantProps & Wrapper.Unwrappable<Unwrapped>

export type GrantProps = {
  policy: string?,
  username: string?,
}

export type Unwrapped = GrantProps

function Grant:new(o: GrantProps): Grant
  return Meta:type(o, self, 'Mcli.Grant')
end

function Grant:from(username: string, policy: string): Grant
  return Grant:new({
    policy = policy,
    username = username,
  })
end

function Grant:unwrap(): Unwrapped
  local this = self::Grant
  return {
    policy = this.policy,
    username = this.username,
  }
end

return Grant
