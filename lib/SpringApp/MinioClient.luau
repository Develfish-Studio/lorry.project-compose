--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local PropTypes = require('@lorry.project/lib/PropTypes')

local MinioClient = {}

export type MinioClient = typeof(MinioClient)

export type MinioClientProps = {
  target_server: string,
  access_key: string,
  secret_key: string,
}

export type Unwrapped = MinioClientProps

export type MinioClientImpl = MinioClient & MinioClientProps & Wrapper.Unwrappable<Unwrapped>


function MinioClient:new(o: MinioClientProps): MinioClient
  return Meta:type(o, self, 'SpringApp.MinioClient')
end

function MinioClient:from_remote(props: PropTypes.MinioRemote): MinioClient
  return MinioClient:new(props)
end

function MinioClient:unwrap(): Unwrapped
  local this = self::MinioClientImpl
  return {
    target_server = this.target_server,
    access_key = this.access_key,
    secret_key = this.secret_key,
  }
end

return MinioClient
