--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Manifest = require('./Manifest/Manifest')

local NginxSpa = {}

export type NginxSpa = typeof(NginxSpa)

export type NginxSpaProps = {
  project: Project.Project,
  name: string,
  image: string?,
  manifest: Manifest.Manifest,
}

export type NginxSpaImpl = NginxSpa & NginxSpaProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

function NginxSpa:new(o: NginxSpaProps): NginxSpa
  return Meta:type(o, self, 'NginxSpa')
end

function NginxSpa:from(project: Project.Project, name: string, image: string?): NginxSpa
  assert(project ~= nil)
  assert(name ~= nil)
  return NginxSpa:new({
    project = project,
    name = name,
    image = image,
    manifest = Manifest:from_empty():with_image(image),
  })
end

function NginxSpa:configure(configurer: {ConfigurerFunc}): NginxSpa
  local this = self::NginxSpaImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function NginxSpa:unwrap(): Unwrapped
  local this = self::NginxSpaImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    },
  }
end

return NginxSpa
