--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Project = require('@lorry.project/lib/Project')
local Wrapper = require('@lorry.project/lib/Wrapper')
local PropTypes = require('@lorry.project/lib/PropTypes')
local Manifest = require('../Manifest/Manifest')
local SpringDatasource = require('./SpringDatasource')
local SpringKafka = require('./SpringKafka')
local OpenidClient = require('./OpenidClient')
local MinioClient = require('./MinioClient')
local MinioBucket = require('./MinioBucket')

local SpringApp = {
  SpringDatasource = SpringDatasource,
  SpringKafka = SpringKafka,
  OpenidClient = OpenidClient,
  MinioClient = MinioClient,
  MinioBucket = MinioBucket,
}

export type SpringApp = typeof(SpringApp)

export type SpringAppProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  spring_datasource: SpringDatasource.SpringDatasource?,
  spring_kafka: SpringKafka.SpringKafka?,
  openid_client: OpenidClient.OpenidClient?,
  minio_client: MinioClient.MinioClient?,
  minio_buckets: {MinioBucket.MinioBucket},
}

export type SpringAppImpl = SpringApp & SpringAppProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
    spring_datasource: SpringDatasource.Unwrapped?,
    spring_kafka: SpringKafka.Unwrapped?,
    openid_client: OpenidClient.Unwrapped?,
    minio_client: MinioClient.Unwrapped?,
    minio_buckets: {MinioBucket.Unwrapped}?,
  }
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild =
  | SpringDatasource.SpringDatasource
  | SpringKafka.SpringKafka
  | OpenidClient.OpenidClient
  | MinioClient.MinioClient
  | MinioBucket.MinioBucket

function SpringApp:new(o: SpringAppProps): SpringApp
  return Meta:type(o, self, 'SpringApp')
end

function SpringApp:from(project: Project.Project, name: string, image: string?): SpringApp
  assert(project ~= nil)
  assert(name ~= nil)
  return SpringApp:new({
    project = project,
    name = name,
    manifest = Manifest:from_empty():with_image(image),
    minio_buckets = Meta:array {},
  })
end

function SpringApp:configure(configurer: {ConfigurerFunc}): SpringApp
  local this = self::SpringAppImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function SpringApp:setup(children: {AnyChild}): SpringApp
  local this = self::SpringAppImpl
  children = children or {}
  for _, child in children do
    this:with_child(child)
  end
  return self
end

function SpringApp:with_child(child: AnyChild): SpringApp
  local this = self::SpringAppImpl
  local tag = Meta:typeof(child)
  if tag == 'SpringApp.SpringDatasource' then
    this.spring_datasource = child::SpringDatasource.SpringDatasource
  elseif tag == 'SpringApp.SpringKafka' then
    this.spring_kafka = child::SpringKafka.SpringKafka
  elseif tag == 'SpringApp.OpenidClient' then
    this.openid_client = child::OpenidClient.OpenidClient
  elseif tag == 'SpringApp.MinioClient' then
    this.minio_client = child::MinioClient.MinioClient
  elseif tag == 'SpringApp.MinioBucket' then
    this.minio_buckets[#this.minio_buckets + 1] = child::MinioBucket.MinioBucket
  end
  return this
end

function SpringApp:with_spring_datasource(ds: PropTypes.Datasource): SpringApp
  local this = self::SpringAppImpl
  this:with_child(SpringDatasource:from_ds(ds))
  return this
end

function SpringApp:with_spring_kafka(remote: PropTypes.KafkaRemote): SpringApp
  local this = self::SpringAppImpl
  this:with_child(SpringKafka:from_remote(remote))
  return this
end

function SpringApp:with_minio_client(remote: PropTypes.MinioRemote): SpringApp
  local this = self::SpringAppImpl
  this:with_child(MinioClient:from_remote(remote))
  return this
end

function SpringApp:with_minio_bucket(name: string, upload_policy: MinioBucket.UploadPolicy?): SpringApp
  local this = self::SpringAppImpl
  this:with_child(MinioBucket:from(name, upload_policy))
  return this
end

function SpringApp:unwrap(): Unwrapped
  local this = self::SpringAppImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap(),
      spring_datasource = Wrapper:unwrap_or_nil(this.spring_datasource),
      spring_kafka = Wrapper:unwrap_or_nil(this.spring_kafka),
      minio_client = Wrapper:unwrap_or_nil(this.minio_client),
      minio_buckets = Wrapper:unwrap_array_or_nil(this.minio_buckets),
    },
  }
end

return SpringApp
