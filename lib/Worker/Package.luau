--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Package = {}

export type Package = typeof(Package) & PackageProps & Wrapper.Unwrappable<Unwrapped>

export type PackageProps = {
  name: string,
}

export type Unwrapped = PackageProps

function Package:new(o: PackageProps): Package
  return Meta:type(o, self, 'Worker.Package')
end

function Package:from_name(name: string): Package
  return Package:new({
    name = name,
  })
end

function Package:unwrap(): Unwrapped
  local this = self::Package
  return {
    name = this.name,
  }
end

return Package
