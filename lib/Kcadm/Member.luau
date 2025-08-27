--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Member = {}

export type Member = typeof(Member) & MemberProps & Wrapper.Unwrappable<Unwrapped>

export type MemberProps = {
  username: string?,
  group: string?,
}

export type Unwrapped = {
  username: string?,
  group: string?,
}

function Member:new(o: MemberProps): Member
  return Meta:type(o, self, 'Kcadm.Member')
end

function Member:from(username: string, group: string): Member
  return Member:new({
    username = username,
    group = group
  })
end

function Member:unwrap(): Unwrapped
  local this = self::Member
  return {
    username = this.username,
    group = this.group
  }
end

return Member
