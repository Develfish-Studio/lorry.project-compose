local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')

export type Kafka = {
  project: Project.Project,
  environment: {[string]: any},
  depends_on: {string},
  links: {string},

  with_link: (self: Kafka, link: string) -> Kafka,
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

local Kafka = {
  project = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
}

function Kafka:new(o): Kafka
  return Meta:type(o, self, 'Kafka')
end

function Kafka:from(project: Project.Project): Kafka
  assert(project ~= nil)
  return Kafka
    :new({
      project = project,
      environment = Meta:table {},
      depends_on = Meta:array {},
      links = Meta:array {},
    })
end

function Kafka.with_env_variables(self: Kafka, environment: {[string]: any}): Kafka
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Kafka.with_depends_on(self: Kafka, name: string): Kafka
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function Kafka.with_link(self: Kafka, link: string): Kafka
  self.links[#self.links + 1] = link
  return self
end

function Kafka.unwrap(self: Kafka): Unwrapped
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

return Kafka