--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')
local Manifest = require('./Manifest')
local ComposeVolume = require('./compose/Volume')
local ComposeNetwork = require('./compose/Network')
local User = require('./mcli/User')
local Key = require('./mcli/Key')
local Grant = require('./mcli/Grant')
local Bucket = require('./mcli/Bucket')
local KafkaTarget = require('./mcli/KafkaTarget')

local Mcli = {
  User = User,
  Key = Key,
  Grant = Grant,
  Bucket = Bucket,
  KafkaTarget = KafkaTarget,
}

export type Mcli = typeof(Mcli)

export type McliImpl = Mcli & McliProps

export type McliProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  users: {User.User},
  keys: {Key.Key},
  grants: {Grant.Grant},
  buckets: {Bucket.Bucket},
  targets: {KafkaTarget.KafkaTarget},
  anonymous_access: {string},
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  users: {User.Unwrapped},
  keys: {Key.Unwrapped},
  grants: {Grant.Unwrapped},
  buckets: {Bucket.Unwrapped},
  targets: {KafkaTarget.Unwrapped},
  anonymous_access: {string},
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  }
}

export type AnyChild = User.User | Key.Key | Grant.Grant | Bucket.Bucket | KafkaTarget.KafkaTarget | Manifest.AnyChild

function Mcli:new(o: McliProps): Mcli
  return Meta:type(o, self, 'Mcli')
end

function Mcli:from(project: Project.Project, name: string): Mcli
  assert(project ~= nil)
  assert(name ~= nil)
  return Mcli
    :new({
      project = project,
      name = name,
      manifest = Manifest:from_empty(),
      users = Meta:array {},
      keys = Meta:array {},
      grants = Meta:array {},
      buckets = Meta:array {},
      targets = Meta:array {},
      anonymous_access = Meta:array {},
    })
end

function Mcli:with_user(username: string, password: string): Mcli
  local this = self::McliImpl
  this:with_child(User:from(username, password))
  return this
end

function Mcli:with_grant(username: string, policy: string): Mcli
  local this = self::McliImpl
  this:with_child(Grant:from(username, policy))
  return this
end

function Mcli:with_key(username: string, access_key: string, secret_key: string): Mcli
  local this = self::McliImpl
  this:with_child(Key:from(username, access_key, secret_key))
  return this
end

function Mcli:with_bucket(name: string): Mcli
  local this = self::McliImpl
  this:with_child(Bucket:from(name))
  return this
end

function Mcli:with_open_bucket(name: string): Mcli
  local this = self::McliImpl
  this:with_child(Bucket:from(name):with_anonymous_access('download'))
  return this
end

function Mcli:with_link(service: string, alias: string?): Mcli
  local this = self::McliImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function Mcli:with_depends_on(service: string): Mcli
  local this = self::McliImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function Mcli:with_volume_ref(volume: ComposeVolume.Volume, path: string): Mcli
  local this = self::McliImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function Mcli:with_volume_source(source: string, path: string): Mcli
  local this = self::McliImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function Mcli:with_network(network: ComposeNetwork.Network): Mcli
  local this = self::McliImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function Mcli:setup(children: {AnyChild}): Mcli
  local this = self::McliImpl
  children = children or {}
  for _, child in children do
    this:with_child(child)
  end
  return self
end

function Mcli:with_child(child: AnyChild): Mcli
  local this = self::McliImpl
  local tag = Meta:typeof(child)
  if tag == 'Mcli.User' then
    this.users[#self.users + 1] = child::User.User
  elseif tag == 'Mcli.Key' then
    this.keys[#self.keys + 1] = child::Key.Key
  elseif tag == 'Mcli.Grant' then
    this.grants[#self.grants + 1] = child::Grant.Grant
  elseif tag == 'Mcli.Bucket' then
    this.buckets[#self.buckets + 1] = child::Bucket.Bucket
  elseif tag == 'Mcli.KafkaTarget' then
    this.targets[#self.targets + 1] = child::KafkaTarget.KafkaTarget
  else
    this.manifest.with_child(self, child::Manifest.AnyChild);
  end
  return this
end

function Mcli:unwrap(): Unwrapped
  local this = self::McliImpl
  return {
    project = this.project:unwrap_project(),
    users = Wrapper:unwrap_array(this.users),
    keys = Wrapper:unwrap_array(this.keys),
    grants = Wrapper:unwrap_array(this.grants),
    buckets = Wrapper:unwrap_array(this.buckets),
    targets = Wrapper:unwrap_array(this.targets),
    anonymous_access = this.anonymous_access,
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    }
  }
end

return Mcli