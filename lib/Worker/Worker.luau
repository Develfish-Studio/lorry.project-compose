local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Project = require('@lorry.project/lib/Project')
local Manifest = require('../Manifest/Manifest')
local Remote = require('./Remote')
local Package = require('./Package')

local Worker = {
  Remote = Remote,
  Package = Package,
}

export type Worker = typeof(Worker) & Wrapper.Unwrappable<Unwrapped>

export type WorkerProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  remote: Remote.Remote?,
  packages: {Package.Package},
}

export type WorkerImpl = Worker & WorkerProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
    remote: Remote.Unwrapped?,
    packages: {Package.Unwrapped}?,
  },
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild =
  | Remote.Remote
  | Package.Package
  | Manifest.AnyChild

function Worker:new(o: WorkerProps)
  return Meta:type(o, self, 'Worker')
end

function Worker:from(project: Project.Project, name: string, image: string?): Worker
  assert(project ~= nil)
  return Worker
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty():with_image(image),
      packages = Meta:array {},
    })
end

function Worker:configure(configurer: {ConfigurerFunc}): Worker
  local this = self::WorkerImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function Worker:setup(children: {AnyChild}): Worker
  local this = self::WorkerImpl
  children = children or {}
  for _, child in children do
    this:with_child(child)
  end
  return self
end

function Worker:with_child(child: AnyChild): Worker
  local this = self::WorkerImpl
  local tag = Meta:typeof(child)
  if tag == 'Worker.Remote' then
    this.remote = child::Remote.Remote
  elseif tag == 'Worker.Package' then
    this.remote = child::Package.Package
  else
    this.manifest.with_child(self, child::Manifest.AnyChild);
  end
  return this
end

function Worker:with_remote(server: string, access_key: string, secret_key: string): Worker
  local this = self::WorkerImpl
  this:with_child(Remote:from(server, access_key, secret_key))
  return this
end

function Worker:with_package(name: string): Worker
  local this = self::WorkerImpl
  this:with_child(Package:from_name(name))
  return this
end

function Worker:with_image(image: string)
  local this = self::Worker
  this.manifest:with_image(image)
  return self
end

function Worker:unwrap()
  local this = self::WorkerImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap(),
      packages = Wrapper:array_or_nil(this.packages),
    },
  }
end

return Worker
