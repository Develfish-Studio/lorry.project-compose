--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')

local Group = {}

export type Group = typeof(Group) & GroupProps

export type GroupProps = {
  name: string?,
}

export type Unwrapped = {
  name: string?,
}

function Group:new(o: GroupProps): Group
  return Meta:type(o, self, 'Kcadm.Group')
end

function Group:from(name: string): Group
  return Group:new({
    name = name,
  })
end

function Group:unwrap(): Unwrapped
  local this = self::Group
  return {
    name = this.name,
  }
end

return Group
