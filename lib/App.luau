local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')

export type App = {
  project: Project.Project,
  name: string?,
  image: string?,
  environment: {[string]: any},
  depends_on: {string},
  links: {string},

  with_depends_on: (self: App, name: string) -> App,
  with_link: (self: App, link: string) -> App,
  with_env_variable: (self: App, name: string, value: string) -> App,
  with_env_variables: (self: App, environment: Environment) -> App,
  with_spring_datasource: (self: App, datasource: { uri: string?, username: string?, password: string? }) -> App,
  with_app_openid_client: (self: App, client: { uri: string?, client_id: string?, client_secret: string?, redirect_uri: string?, issuer_uri: string? }) -> App,
  with_app_minio_client: (self: App, client: { uri: string, access_key: string?, secret_key: string? }) -> App,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string?,
    manifest: {
      image: string?,
      environment: {[string]: any},
      depends_on: {string}?,
      links: {string}?,
    }
  }
}

local App = {
  project = nil,
  name = nil,
  image = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
}

export type Environment = {
  [string]: any
}

function App:new(o): App
  return Meta:type(o, self, 'App')
end

function App:from(project: Project.Project, name: string, image: string, environment: Environment?): App
  assert(project ~= nil)
  return App:new({
    project = project,
    name = name,
    image = image,
    depends_on = Meta:array {},
    links = Meta:array {},
    environment = environment or Meta:table {},
  })
end

function App.with_env_variable(self: App, name: string, value: string): App
  self.environment[name] = value
  return self
end

function App.with_env_variables(self: App, environment: Environment): App
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function App.with_spring_datasource(self: App, datasource: { uri: string?, username: string?, password: string? }): App
  assert(datasource ~= nil)
  assert(datasource.uri ~= nil)
  return self:with_env_variables({
    SPRING_DATASOURCE_URL = datasource.uri,
    SPRING_DATASOURCE_USERNAME = datasource.username,
    SPRING_DATASOURCE_PASSWORD = datasource.password,
  })
end

function App.with_app_openid_client(self: App, client: { uri: string?, client_id: string?, client_secret: string?, redirect_uri: string?, issuer_uri: string? }): App
  assert(client ~= nil)
  assert(client.client_id ~= nil)
  assert(client.client_secret ~= nil)
  return self:with_env_variables({
    APP_OPENID_CLIENT_CLIENTID = client.client_id,
    APP_OPENID_CLIENT_CLIENTSECRET = client.client_secret,
    APP_OPENID_CLIENT_REDIRECTURI = client.redirect_uri,
    APP_OPENID_CLIENT_ISSUERURI = client.issuer_uri,
  })
end

function App.with_app_minio_client(self: App, client: { uri: string, access_key: string?, secret_key: string? }): App
  assert(client ~= nil)
  assert(client.uri ~= nil)
  assert(client.access_key ~= nil)
  assert(client.secret_key ~= nil)
  return self:with_env_variables({
    APP_MINIO_CLIENT_TARGET_SERVER = client.uri,
    APP_MINIO_CLIENT_ACCESS_KEY = client.access_key,
    APP_MINIO_CLIENT_SECRET_KEY = client.secret_key,
  })
end

function App.with_depends_on(self: App, name: string): App
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function App.with_link(self: App, link: string): App
  self.links[#self.links + 1] = link
  return self
end

function App.unwrap(self: App): Unwrapped
  return {
    project = self.project:unwrap_project(),
    service = {
      name = self.name,
      manifest = {
        image = self.image,
        environment = self.environment,
        depends_on = Wrapper:array_or_nil(self.depends_on),
        links = Wrapper:array_or_nil(self.links),
      }
    },
  }
end

return App
