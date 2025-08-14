local Meta = require('@develfish-repo.utils/lib/Meta')
local String = require('@develfish-repo.utils/lib/String')

local Link = {}

export type Link = typeof(Link) & LinkProps

export type LinkProps = {
  service: string,
  alias: string?,
}

function Link:new(o: LinkProps): Link
  return Meta:type(o, self, 'Manifest.Link')
end

function Link:from(service: string, alias: string?): Link
  return Link:new({
    service = service,
    alias = alias,
  })
end

function Link:parse(link: string): Link
  local st = String:split(link, String.EXPR_DOT)
  return Link:new({
    service = st[1],
    alias = st[2],
  })
end

return Link
