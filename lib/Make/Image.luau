--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Image = {}

export type Image = typeof(Image) & ImageProps & Wrapper.Unwrappable<Unwrapped>

export type ImageProps = {
  name: string,
  bundle: string,
  namespace: string,
  version: string?,
  context: string?,
}

export type Unwrapped = ImageProps

function Image:new(o: ImageProps): Image
  return Meta:type(o, self, 'Make.Image')
end

function Image:with_version(version: string): Image
  local this = self::Image
  this.version = version
  return this
end

function Image:with_context(context: string): Image
  local this = self::Image
  this.context = context
  return this
end

function Image:from(name: string, bundle: string, namespace: string): Image
  return Image:new({
    name = name,
    bundle = bundle,
    namespace = namespace,
  })
end

function Image:unwrap(): Unwrapped
  local this = self::Image
  return {
    name = this.name,
    bundle = this.bundle,
    namespace = this.namespace,
    version = this.version,
    context = this.context,
  }
end

return Image
