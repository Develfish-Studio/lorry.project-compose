--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Manifest = require('../Manifest/Manifest')
local Cluster = require('./Cluster')

local KafkaUi = {
  Cluster = Cluster
}

export type KafkaUi = typeof(KafkaUi)

export type KafkaUiProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  clusters: {Cluster.Cluster},
}

export type KafkaUiImpl = KafkaUi & KafkaUiProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
    clusters: {Cluster.Unwrapped}?,
  }
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild =
  | Cluster.Cluster
  | Manifest.AnyChild

function KafkaUi:new(o: KafkaUiProps): KafkaUi
  return Meta:type(o, self, 'KafkaUi')
end

function KafkaUi:from(project: Project.Project, name: string): KafkaUi
  assert(project ~= nil)
  assert(name ~= nil)
  return KafkaUi
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
      clusters = Meta:array {},
    })
end

function KafkaUi:configure(configurer: {ConfigurerFunc}): KafkaUi
  local this = self::KafkaUiImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function KafkaUi:setup(children: {AnyChild}): KafkaUi
  local this = self::KafkaUiImpl
  children = children or Meta:array {}
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function KafkaUi:with_child(child: AnyChild): KafkaUi
  local this = self::KafkaUiImpl
  local tag = Meta:typeof(child)
  if tag == 'KafkaUi.Cluster' then
    this.clusters[#this.clusters + 1] = child::Cluster.Cluster
  else
    this.manifest:with_child(child::Manifest.AnyChild)
  end
  return this
end

function KafkaUi:with_cluster(name: string, bootstrap_servers: string): KafkaUi
  local this = self::KafkaUiImpl
  this:with_child(Cluster:from(name, bootstrap_servers))
  return this
end

function KafkaUi:unwrap(): Unwrapped
  local this = self::KafkaUiImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap(),
      clusters = Wrapper:unwrap_array_or_nil(this.clusters),
    }
  }
end

return KafkaUi