--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local MinioBucket = {}

export type MinioBucket = typeof(MinioBucket) & MinioBucketProps & Wrapper.Unwrappable<Unwrapped>

export type MinioBucketProps = {
  name: string?,
  upload_policy: UploadPolicy?,
}

export type UploadPolicy = {
  content_type: string?,
  content_length: string?,
}

export type Unwrapped = MinioBucketProps

function MinioBucket:new(o: MinioBucketProps): MinioBucket
  return Meta:type(o, self, 'SpringApp.MinioBucket')
end

function MinioBucket:from(name: string, upload_policy: UploadPolicy?): MinioBucket
  return MinioBucket:new({
    name = name,
    upload_policy = upload_policy,
  })
end

function MinioBucket:unwrap(): Unwrapped
  local this = self::MinioBucket
  return {
    name = this.name,
    upload_policy = this.upload_policy,
  }
end

return MinioBucket
