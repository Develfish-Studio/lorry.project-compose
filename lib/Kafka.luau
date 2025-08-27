--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Project = require('@lorry.project/lib/Project')
local Manifest = require('./Manifest/Manifest')

local Kafka = {}

export type Kafka = typeof(Kafka)

export type KafkaProps = {
  project: Project.Project,
  name: string,
  cluster_id: string?,
  manifest: Manifest.Manifest,
}

export type KafkaImpl = Kafka & KafkaProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    cluster_id: string?,
    manifest: Manifest.Unwrapped,
  }
}

export type Datasource = { uri: string?, username: string?, password: string? }

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild = Manifest.AnyChild

function Kafka:new(o: KafkaProps): Kafka
  return Meta:type(o, self, 'Kafka')
end

function Kafka:from(project: Project.Project, name: string): Kafka
  assert(project ~= nil)
  assert(name ~= nil)
  return Kafka
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
    })
end

function Kafka:configure(configurer: {ConfigurerFunc}): Kafka
  local this = self::KafkaImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function Kafka:setup(children: {AnyChild}): Kafka
  local this = self::KafkaImpl
  children = children or Meta:array {}
  for _, child in children do
    this.manifest:with_child(child::Manifest.AnyChild)
  end
  return this
end

function Kafka:with_cluster_id(cluster_id: string): Kafka
  local this = self::KafkaImpl
  this.cluster_id = cluster_id
  return this
end

function Kafka:unwrap(): Unwrapped
  local this = self::KafkaImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      cluster_id = this.cluster_id,
      manifest = this.manifest:unwrap()
    }
  }
end

return Kafka
