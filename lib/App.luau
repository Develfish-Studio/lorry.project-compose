--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Manifest = require('./Manifest')
local ComposeVolume = require('./Compose/Volume')
local ComposeNetwork = require('./Compose/Network')

local App = {}

export type App = typeof(App)

export type AppImpl = App & AppProps

export type AppProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  image: string?,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

function App:new(o: AppProps): App
  return Meta:type(o, self, 'App')
end

function App:from(project: Project.Project, name: string, image: string): App
  assert(project ~= nil)
  return App:new({
    project = project,
    name = name,
    image = image,
    manifest = Manifest:from_empty()
  })
end

function App:with_env_variable(name: string, value: string): App
  local this = self::AppImpl
  this.manifest:with_env_variable(name, value)
  return self
end

function App:with_env_variables(environment: Manifest.Environment): App
  local this = self::AppImpl
  environment = environment or Meta:table {}
  for name, value in environment do
    this.manifest:with_env_variable(name, value)
  end
  return this
end

function App:with_spring_datasource(datasource: { uri: string?, username: string?, password: string? }): App
  local this = self::AppImpl
  assert(datasource ~= nil)
  assert(datasource.uri ~= nil)
  return this:with_env_variables({
    SPRING_DATASOURCE_URL = datasource.uri,
    SPRING_DATASOURCE_USERNAME = datasource.username,
    SPRING_DATASOURCE_PASSWORD = datasource.password,
  })
end

function App:with_app_openid_client(client: { uri: string?, client_id: string?, client_secret: string?, redirect_uri: string?, issuer_uri: string? }): App
  local this = self::AppImpl
  assert(client ~= nil)
  assert(client.client_id ~= nil)
  assert(client.client_secret ~= nil)
  return this:with_env_variables({
    APP_OPENID_CLIENT_CLIENTID = client.client_id,
    APP_OPENID_CLIENT_CLIENTSECRET = client.client_secret,
    APP_OPENID_CLIENT_REDIRECTURI = client.redirect_uri,
    APP_OPENID_CLIENT_ISSUERURI = client.issuer_uri,
  })
end

function App:with_app_minio_client(client: { uri: string, access_key: string?, secret_key: string? }): App
  local this = self::AppImpl
  assert(client ~= nil)
  assert(client.uri ~= nil)
  assert(client.access_key ~= nil)
  assert(client.secret_key ~= nil)
  return this:with_env_variables({
    APP_MINIO_CLIENT_TARGET_SERVER = client.uri,
    APP_MINIO_CLIENT_ACCESS_KEY = client.access_key,
    APP_MINIO_CLIENT_SECRET_KEY = client.secret_key,
  })
end

function App:with_link(service: string, alias: string?): App
  local this = self::AppImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function App:with_depends_on(service: string): App
  local this = self::AppImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function App:with_volume_ref(volume: ComposeVolume.Volume, path: string): App
  local this = self::AppImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function App:with_volume_source(source: string, path: string): App
  local this = self::AppImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function App:with_network(network: ComposeNetwork.Network): App
  local this = self::AppImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function App:unwrap(): Unwrapped
  local this = self::AppImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    },
  }
end

return App
