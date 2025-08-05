local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')

export type Minio = {
  project: Project.Project,
  environment: {[string]: any},
  depends_on: {string},
  links: {string},

  with_link: (self: Minio, link: string) -> Minio,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    manifest: {
      environment: {[string]: any},
      depends_on: {string}?,
      links: {string}?,
    }
  }
}

local Minio = {
  project = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
}

function Minio:new(o): Minio
  return Meta:type(o, self, 'Minio')
end

function Minio:from(project: Project.Project): Minio
  assert(project ~= nil)
  return Minio
    :new({
      project = project,
      environment = Meta:table {},
      depends_on = Meta:array {},
      links = Meta:array {},
    })
end

function Minio.with_env_variables(self: Minio, environment: {[string]: any}): Minio
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Minio.with_depends_on(self: Minio, name: string): Minio
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function Minio.with_link(self: Minio, link: string): Minio
  self.links[#self.links + 1] = link
  return self
end

function Minio.unwrap(self: Minio): Unwrapped
  return {
    project = self.project:unwrap_project(),
    service = {
      manifest = {
        environment = self.environment,
        depends_on = Wrapper:array_or_nil(self.depends_on),
        links = Wrapper:array_or_nil(self.links),
      }
    }
  }
end

return Minio