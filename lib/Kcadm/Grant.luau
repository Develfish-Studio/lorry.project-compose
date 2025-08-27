--!strict

local Meta = require('@lorry.utils/lib/Meta')
local URI = require('@lorry.utils/lib/URI')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Grant = {}

export type Grant = typeof(Grant) & GrantProps & Wrapper.Unwrappable<Unwrapped>

export type GrantProps = {
  kind: string?,
  username: string?,
  group: string?,
  client: string?,
  role: string?,
}

export type Unwrapped = {
  kind: string?,
  username: string?,
  group: string?,
  client: string?,
  role: string?,
}

function Grant:new(o: GrantProps): Grant
  return Meta:type(o, self, 'Kcadm.Grant')
end

function Grant:from(target_uri_string: string, role_uri_string: string): Grant
  local kind = nil
  local username = nil
  local group = nil
  local client = nil
  local role = nil

  local target_uri = URI:parse(target_uri_string)

  if target_uri.schema == 'user' then
    kind = 'user'
    username = target_uri.path
  elseif target_uri.schema == 'group' then
    kind = 'group'
    group = target_uri.path
  else
    error(`Unsupported target schema: '{target_uri.schema}'`)
  end

  local role_uri = URI:parse(role_uri_string)

  if role_uri.schema == 'realm' then
    role = role_uri.path
  elseif target_uri.schema == 'client' then
    local client_role_uri = URI:parse(target_uri.path::string)
    client = client_role_uri.schema
    role = client_role_uri.path
  else
    error(`Unsupported role schema: '{role_uri.schema}'`)
  end

  return Grant:new({
    kind = kind,
    username = username,
    group = group,
    client = client,
    role = role,
  })
end

function Grant:unwrap(): Unwrapped
  local this = self::Grant
  return {
    kind = this.kind,
    username = this.username,
    group = this.group,
    client = this.client,
    role = this.role,
  }
end

return Grant
