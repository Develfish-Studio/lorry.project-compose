local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')

export type Spa = {
  project: Project.Project,
  name: string?,
  image: string?,
  environment: {[string]: any},
  depends_on: {string},
  links: {string},
  volumes: {string},

  with_env_variable: (self: Spa, name: string, value: string) -> Spa,
  with_env_variables: (self: Spa, environment: {[string]: any}) -> Spa,

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
      volumes: {string}?,
    }
  }
}

local Spa = {
  project = nil,
  name = nil,
  image = nil,
  environment = nil,
  volumes = nil,
}

function Spa:new(o)
  return Meta:type(o, self, 'Spa')
end

function Spa:from(project: Project.Project, name: string, image: string, environment: {[string]: any}?): Spa
  assert(project ~= nil)
  return Spa:new({
    project = project,
    name = name,
    image = image,
    volumes = Meta:array {},
    environment = environment or Meta:table {},
  })
end

function Spa.with_env_variable(self: Spa, name: string, value: string): Spa
  self.environment[name] = value
  return self
end

function Spa.with_env_variables(self: Spa, environment: {[string]: any}): Spa
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Spa.unwrap(self: Spa): Unwrapped
  return {
    project = self.project:unwrap_project(),
    service = {
      manifest = {
        image = self.image,
        environment = self.environment,
        depends_on = Wrapper:array_or_nil(self.depends_on),
        links = Wrapper:array_or_nil(self.links),
        volumes = Meta:array {
          `../../config/app/{self.name}/templates:/etc/nginx/templates`
        }
      }
    }
  }
end

return Spa
