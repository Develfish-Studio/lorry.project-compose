--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')

local Profile = {}

export type Profile = typeof(Profile) & ProfileProps

export type ProfileProps = {
  name: string,
}

function Profile:new(o: ProfileProps): Profile
  return Meta:type(o, self, 'Manifest.Profile')
end

function Profile:from(name: string): Profile
  assert(name ~= nil)
  return Profile:new({
    name = name
  })
end

return Profile
