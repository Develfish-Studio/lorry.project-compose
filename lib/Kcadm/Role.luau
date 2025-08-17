--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Role = {}

export type Role = typeof(Role) & RoleProps & Wrapper.Unwrappable<Unwrapped>

export type RoleProps = {
  name: string?,
  client_name: string?,
}

export type Unwrapped = {
  name: string?,
  client: string?,
}

function Role:new(o: RoleProps): Role
  return Meta:type(o, self, 'Kcadm.Role')
end

function Role:from(name: string): Role
  return Role:new({
    name = name,
  })
end

function Role:realm(name: string): Role
  return Role:new({
    name = name,
  })
end

function Role:client(client_name: string, name: string): Role
  return Role:new({
    name = name,
    client_name = client_name,
  })
end

function Role:unwrap(): Unwrapped
  local this = self::Role
  return {
    name = this.name,
    client = this.client_name,
  }
end

return Role
