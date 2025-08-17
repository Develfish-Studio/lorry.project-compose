--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
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

function SpringApp:with_spring_datasource(props: SpringDatasource.SpringDatasourceProps): SpringApp
  local this = self::SpringAppImpl
  this:with_child(SpringDatasource:from(props))
  return this
end

function SpringApp:with_spring_kafka(props: SpringKafka.SpringKafkaProps): SpringApp
  local this = self::SpringAppImpl
  this:with_child(SpringKafka:from(props))
  return this
end

function SpringApp:with_minio_client(props: MinioClient.MinioClientProps): SpringApp
  local this = self::SpringAppImpl
  this:with_child(MinioClient:from(props))
  return this
end

function SpringApp:with_minio_bucket(name: string, upload_policy: MinioBucket.UploadPolicy?): SpringApp
  local this = self::SpringAppImpl
  this:with_child(MinioBucket:from(name, upload_policy))
  return this
end

-- function SpringApp:with_spring_datasource(datasource: { uri: string?, username: string?, password: string? }): SpringApp
--   local this = self::SpringAppImpl
--   assert(datasource ~= nil)
--   assert(datasource.uri ~= nil)
--   return this:with_env_variables({
--     SPRING_DATASOURCE_URL = datasource.uri,
--     SPRING_DATASOURCE_USERNAME = datasource.username,
--     SPRING_DATASOURCE_PASSWORD = datasource.password,
--   })
-- end

-- function SpringApp:with_app_openid_client(client: { uri: string?, client_id: string?, client_secret: string?, redirect_uri: string?, issuer_uri: string? }): SpringApp
--   local this = self::SpringAppImpl
--   assert(client ~= nil)
--   assert(client.client_id ~= nil)
--   assert(client.client_secret ~= nil)
--   return this:with_env_variables({
--     APP_OPENID_CLIENT_CLIENTID = client.client_id,
--     APP_OPENID_CLIENT_CLIENTSECRET = client.client_secret,
--     APP_OPENID_CLIENT_REDIRECTURI = client.redirect_uri,
--     APP_OPENID_CLIENT_ISSUERURI = client.issuer_uri,
--   })
-- end

-- function SpringApp:with_app_minio_client(client: { uri: string, access_key: string?, secret_key: string? }): SpringApp
--   local this = self::SpringAppImpl
--   assert(client ~= nil)
--   assert(client.uri ~= nil)
--   assert(client.access_key ~= nil)
--   assert(client.secret_key ~= nil)
--   return this:with_env_variables({
--     APP_MINIO_CLIENT_TARGET_SERVER = client.uri,
--     APP_MINIO_CLIENT_ACCESS_KEY = client.access_key,
--     APP_MINIO_CLIENT_SECRET_KEY = client.secret_key,
--   })
-- end

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
