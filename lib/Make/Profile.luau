--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Profile = {}

export type Profile = typeof(Profile) & ProfileProps & Wrapper.Unwrappable<Unwrapped>

export type ProfileProps = {
  name: string,
}

export type Unwrapped = ProfileProps

function Profile:new(o: ProfileProps): Profile
  return Meta:type(o, self, 'Make.Profile')
end

function Profile:from(name: string): Profile
  return Profile:new({
    name = name,
  })
end


function Profile:unwrap(): Unwrapped
  local this = self::Profile
  return {
    name = this.name,
  }
end

return Profile
