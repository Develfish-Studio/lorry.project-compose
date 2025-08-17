--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local OpenidClient = {}

export type OpenidClient = typeof(OpenidClient)

export type OpenidClientProps = {
  redirect_uri: string,
  issuer_uri: string,
  client_id: string,
  client_secret: string,
}

export type Unwrapped = OpenidClientProps

export type OpenidClientImpl = OpenidClient & OpenidClientProps & Wrapper.Unwrappable<Unwrapped>


function OpenidClient:new(o: OpenidClientProps): OpenidClient
  return Meta:type(o, self, 'SpringApp.OpenidClient')
end

function OpenidClient:from(props: OpenidClientProps): OpenidClient
  return OpenidClient:new(props)
end

function OpenidClient:unwrap(): Unwrapped
  local this = self::OpenidClientImpl
  return {
    redirect_uri = this.redirect_uri,
    issuer_uri = this.issuer_uri,
    client_id = this.client_id,
    client_secret = this.client_secret,
  }
end

return OpenidClient
