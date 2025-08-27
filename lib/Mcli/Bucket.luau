--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Bucket = {}

export type Bucket = typeof(Bucket) & BucketProps & Wrapper.Unwrappable<Unwrapped>

export type BucketProps = {
  name: string?,
  anonymous_access: {string},
}

export type Unwrapped = BucketProps

function Bucket:new(o: BucketProps): Bucket
  return Meta:type(o, self, 'Mcli.Bucket')
end

function Bucket:from(name: string): Bucket
  return Bucket:new({
    name = name,
    anonymous_access = Meta:array {},
    events = Meta:array {},
  })
end

function Bucket:with_anonymous_access(command: string): Bucket
  local this = self::Bucket
  this.anonymous_access[#this.anonymous_access + 1] = command
  return this
end

function Bucket:unwrap(): Unwrapped
  local this = self::Bucket
  return {
    name = this.name,
    anonymous_access = this.anonymous_access,
  }
end

return Bucket
