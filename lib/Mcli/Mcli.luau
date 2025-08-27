--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Project = require('@lorry.project/lib/Project')
local Wrapper = require('@lorry.project/lib/Wrapper')
local PropTypes = require('@lorry.project/lib/PropTypes')
local Manifest = require('../Manifest/Manifest')
local User = require('./User')
local Key = require('./Key')
local Grant = require('./Grant')
local Bucket = require('./Bucket')
local KafkaTarget = require('./KafkaTarget')
local Event = require('./Event')
local Remote = require('./Remote')

local Mcli = {
  User = User,
  Key = Key,
  Grant = Grant,
  Bucket = Bucket,
  KafkaTarget = KafkaTarget,
  Event = Event,
  Remote = Remote,
}

export type Mcli = typeof(Mcli)

export type McliProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  remote: Remote.Remote?,
  users: {User.User},
  keys: {Key.Key},
  grants: {Grant.Grant},
  buckets: {Bucket.Bucket},
  targets: {KafkaTarget.KafkaTarget},
  anonymous_access: {string},
}

export type McliImpl = Mcli & McliProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
    remote: Remote.Unwrapped?,
    users: {User.Unwrapped},
    keys: {Key.Unwrapped},
    grants: {Grant.Unwrapped},
    buckets: {Bucket.Unwrapped},
    targets: {KafkaTarget.Unwrapped},
    anonymous_access: {string},
  }
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild =
  | Remote.Remote
  | User.User
  | Key.Key
  | Grant.Grant
  | Bucket.Bucket
  | KafkaTarget.KafkaTarget
  | Manifest.AnyChild

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
      remote = nil,
      users = Meta:array {},
      keys = Meta:array {},
      grants = Meta:array {},
      buckets = Meta:array {},
      targets = Meta:array {},
      anonymous_access = Meta:array {},
    })
end

function Mcli:configure(configurer: {ConfigurerFunc}): Mcli
  local this = self::McliImpl
  for _, func in configurer do
    func(this.manifest)
  end
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
  if tag == 'Mcli.Remote' then
    this.remote = child::Remote.Remote
  elseif tag == 'Mcli.User' then
    this.users[#this.users + 1] = child::User.User
  elseif tag == 'Mcli.Key' then
    this.keys[#this.keys + 1] = child::Key.Key
  elseif tag == 'Mcli.Grant' then
    this.grants[#this.grants + 1] = child::Grant.Grant
  elseif tag == 'Mcli.Bucket' then
    this.buckets[#this.buckets + 1] = child::Bucket.Bucket
  elseif tag == 'Mcli.KafkaTarget' then
    this.targets[#this.targets + 1] = child::KafkaTarget.KafkaTarget
  else
    this.manifest.with_child(self, child::Manifest.AnyChild);
  end
  return this
end

function Mcli:with_remote(remote: PropTypes.MinioRemote): Mcli
  local this = self::McliImpl
  this:with_child(Remote:new(remote))
  return this
end

function Mcli:with_target(target_server: string, access_key: string, secret_key: string): Mcli
  local this = self::McliImpl
  this:with_child(Remote:from(target_server, access_key, secret_key))
  return this
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

function Mcli:unwrap(): Unwrapped
  local this = self::McliImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap(),
      remote = Wrapper:unwrap_or_nil(this.remote),
      users = Wrapper:unwrap_array(this.users),
      keys = Wrapper:unwrap_array(this.keys),
      grants = Wrapper:unwrap_array(this.grants),
      buckets = Wrapper:unwrap_array(this.buckets),
      targets = Wrapper:unwrap_array(this.targets),
      anonymous_access = this.anonymous_access,
    }
  }
end

return Mcli
