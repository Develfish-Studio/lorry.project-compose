local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')
local Volume = require('@root/lib/general/Volume')

export type Worker = {
  project: Project.Project,
  name: string?,
  image: string?,
  environment: {[string]: any},
  depends_on: {string},
  links: {string},
  packages: {string},
  volumes: {Volume.Volume},

  with_env_variable: (self: Worker, name: string, value: string) -> Worker,
  with_env_variables: (self: Worker, environment: {[string]: any}) -> Worker,

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
  },
  volumes: {[string]: {[string]:any}},
  container: {
    packages: {string}?,
  },
}

local Worker = {
  Volume = Volume,

  project = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
  image = nil,
  packages = nil,
  volumes = nil,
}

function Worker:new(o)
  return Meta:type(o, self, 'Worker')
end

function Worker:from(project: Project.Project, name: string, image: string, environment: {[string]: any}?): Worker
  assert(project ~= nil)
  return Worker
    :new({
      project = project,
      name = name,
      image = image,
      depends_on = Meta:array {},
      links = Meta:array {},
      environment = environment or Meta:table {},
      packages = Meta:array {},
      volumes = Meta:array {},
    })
end

function Worker:with_image(image: string)
  self.image = image
  return self
end

function Worker:with_volume(name: string, path: string)
  self.volumes[#self.volumes + 1] = {
    name = name,
    path = path,
  }
  return self
end

function Worker.with_env_variables(self: Worker, environment: {[string]: any}): Worker
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Worker.with_minio_client(self: Worker, client: {uri: string?, access_key: string?, secret_key: string?}): Worker
  assert(client ~= nil)
  assert(client.uri ~= nil)
  assert(client.access_key ~= nil)
  assert(client.secret_key ~= nil)
  return self:with_env_variables({
    MINIO_TARGET_SERVER = client.uri,
    MINIO_ACCESS_KEY = client.access_key,
    MINIO_SECRET_KEY = client.secret_key,
  })
end

function Worker.with_depends_on(self: Worker, name: string): Worker
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function Worker.with_link(self: Worker, link: string): Worker
  self.links[#self.links + 1] = link
  return self
end

function Worker.with_package(self: Worker, package: string): Worker
  self.packages[#self.packages + 1] = package
  return self
end

function Worker.with_packages(self: Worker, collection: {string}): Worker
  for _, item in collection do
    self.packages[#self.packages + 1] = item
  end
  return self
end

function Worker.unwrap_volume_refs(self: Worker): {string}?
  if #self.volumes > 0 then
    local array = Meta:array {}
    for _, volume in self.volumes do
      local unwrapped = volume:unwrap()
      array[#array + 1] = `{unwrapped.name}..{unwrapped.path}`
    end
    return array
  end

  return nil
end

function Worker.unwrap_volumes(self: Worker): {[string]: any}?
  if #self.volumes > 0 then
    local map = Meta:table {}
    for _, volume in self.volumes do
      if (volume.name ~= nil) then
        map[volume.name] = Meta:table {}
      end
    end
    return map
  end

  return nil
end

function Worker:unwrap()
  return {
    project = self.project:unwrap_project(),
    service = {
      name = self.name,
      manifest = {
        image = self.image,
        environment = self.environment,
        depends_on = Wrapper:array_or_nil(self.depends_on),
        links = Wrapper:array_or_nil(self.links),
        volumes = self:unwrap_volume_refs(),
      }
    },
    container = {
      packages = Wrapper:array_or_nil(self.packages),
    },
    volumes = self:unwrap_volumes()
  }
end

return Worker
