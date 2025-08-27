--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Project = require('@lorry.project/lib/Project')
local Manifest = require('./Manifest/Manifest')

local Service = {}

export type Service = typeof(Service)

export type ServiceProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
}

export type ServiceImpl = Service & ServiceProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild = Manifest.AnyChild

function Service:new(o: ServiceProps): Service
  return Meta:type(o, self, 'Service')
end

function Service:from(project: Project.Project, name: string): Service
  assert(project ~= nil)
  assert(name ~= nil)
  return Service
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
    })
end

function Service:configure(configurer: {ConfigurerFunc}): Service
  local this = self::ServiceImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function Service:setup(children: {AnyChild}): Service
  local this = self::ServiceImpl
  children = children or Meta:array {}

  for _, child in children do
    this.manifest:with_child(child)
  end

  return this
end

function Service:unwrap(): Unwrapped
  local this = self::ServiceImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    }
  }
end

return Service