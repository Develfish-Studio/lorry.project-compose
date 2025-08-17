--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Manifest = require('../Manifest/Manifest')

local Minio = {}

export type Minio = typeof(Minio)

export type MinioProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  admin: AdminData?
}

export type AdminData = {
  username: string,
  password: string,
}

export type MinioImpl = Minio & MinioProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
    admin: AdminData?
  }
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild =
  | Manifest.AnyChild

function Minio:new(o: MinioProps): Minio
  return Meta:type(o, self, 'Minio')
end

function Minio:from(project: Project.Project, name: string): Minio
  assert(project ~= nil)
  assert(name ~= nil)
  return Minio
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
      databases = Meta:array {},
    })
end

function Minio:configure(configurer: {ConfigurerFunc}): Minio
  local this = self::MinioImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function Minio:setup(children: {AnyChild}): Minio
  local this = self::MinioImpl
  children = children or Meta:array {}
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Minio:with_child(child: AnyChild): Minio
  local this = self::MinioImpl
  this.manifest:with_child(child::Manifest.AnyChild)
  return this
end

function Minio:with_admin(username: string, password: string): Minio
  local this = self::MinioImpl
  this.admin = {
    username = username,
    password = password,
  }
  return this
end

function Minio:unwrap(): Unwrapped
  local this = self::MinioImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap(),
      admin = this.admin,
    }
  }
end

return Minio
