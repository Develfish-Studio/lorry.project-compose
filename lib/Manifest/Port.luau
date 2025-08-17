--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local String = require('@develfish-repo.utils/lib/String')

local Port = {}

export type Port = typeof(Port) & PortProps

export type PortProps = {
  --- Host port
  host: string,
  --- Container port
  container: string,
}

function Port:new(o: PortProps): Port
  return Meta:type(o, self, 'Manifest.Port')
end

function Port:from_string(st: string): Port
  local parts = String:split(st, String.EXPR_COLON)
  return Port:from(parts[1], parts[2])
end

function Port:from(host: string, container: string): Port
  assert(host ~= nil)
  assert(container ~= nil)
  return Port:new({
    host = host,
    container = container,
  })
end

return Port
