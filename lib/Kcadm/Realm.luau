--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Realm = {}

export type Realm = typeof(Realm) & RealmProps & Wrapper.Unwrappable<Unwrapped>

export type RealmProps = {
  name: string?
}

export type Unwrapped = {
  name: string?
}

function Realm:new(o: RealmProps): Realm
  return Meta:type(o, self, 'Kcadm.Realm')
end

function Realm:from(name: string): Realm
  return Realm:new({
    name = name,
  })
end

function Realm:unwrap(): Unwrapped
  local this = self::Realm
  return {
    name = this.name,
  }
end

return Realm
