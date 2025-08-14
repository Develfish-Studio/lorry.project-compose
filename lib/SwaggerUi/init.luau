--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Manifest = require('./Manifest')
local Entry = require('./SwaggerUi/Entry')
local ComposeVolume = require('./Compose/Volume')
local ComposeNetwork = require('./Compose/Network')

local SwaggerUi = {}

export type SwaggerUi = typeof(SwaggerUi)

export type SwaggerUiProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  entries: {Entry.Entry},
}

export type SwaggerUiImpl = SwaggerUi & SwaggerUiProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  config: {
    urls: {Entry.Unwrapped}
  },
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type AnyChild = Entry.Entry | Manifest.AnyChild

function SwaggerUi:new(o: SwaggerUiProps): SwaggerUi
  return Meta:type(o, self, 'SwaggerUi')
end

function SwaggerUi:from(project: Project.Project, name: string): SwaggerUi
  assert(project ~= nil)
  assert(name ~= nil)
  return SwaggerUi
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
      entries = Meta:array {},
    })
end

function SwaggerUi:with_entry(name: string, url: string): SwaggerUi
  local this = self::SwaggerUiImpl
  this.entries[#this.entries + 1] = Entry:from(name, url)
  return this
end

function SwaggerUi:with_link(service: string, alias: string?): SwaggerUi
  local this = self::SwaggerUiImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function SwaggerUi:with_depends_on(service: string): SwaggerUi
  local this = self::SwaggerUiImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function SwaggerUi:with_volume_ref(volume: ComposeVolume.Volume, path: string): SwaggerUi
  local this = self::SwaggerUiImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function SwaggerUi:with_volume_source(source: string, path: string): SwaggerUi
  local this = self::SwaggerUiImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function SwaggerUi:with_network(network: ComposeNetwork.Network): SwaggerUi
  local this = self::SwaggerUiImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function SwaggerUi:setup(children: {AnyChild}): SwaggerUi
  local this = self::SwaggerUiImpl
  children = children or Meta:array {}

  for _, child in children do
    local tag = Meta:typeof(child)
    if tag == 'SwaggerUi.Entry' then
      this.entries[#self.entries + 1] = child::Entry.Entry
    else
      this.manifest:with_child(child::Manifest.AnyChild)
    end
  end

  return this
end

function SwaggerUi:unwrap(): Unwrapped
  local this = self::SwaggerUiImpl
  return {
    project = this.project:unwrap_project(),
    config = {
      urls = Wrapper:unwrap_array(this.entries),
    },
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    }
  }
end

return SwaggerUi
