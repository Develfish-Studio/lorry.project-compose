local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')
local User = require('@root/lib/mcli/User')
local Key = require('@root/lib/mcli/Key')
local Grant = require('@root/lib/mcli/Grant')
local Bucket = require('@root/lib/mcli/Bucket')
local KafkaTarget = require('@root/lib/mcli/KafkaTarget')

export type Mcli = {
  project: Project.Project,
  users: {User.User},
  keys: {Key.Key},
  grants: {Grant.Grant},
  buckets: {Bucket.Bucket},
  targets: {KafkaTarget.KafkaTarget},
  anonymous_access: {string},

  with_rules: (self: Mcli, children: {any}) -> Mcli,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  project: Project.Unwrapped,
  users: {User.Unwrapped},
  keys: {Key.Unwrapped},
  grants: {Grant.Unwrapped},
  buckets: {Bucket.Unwrapped},
  targets: {KafkaTarget.Unwrapped},
  anonymous_access: {string},
}

local Mcli = {
  User = User,
  Key = Key,
  Grant = Grant,
  Bucket = Bucket,
  KafkaTarget = KafkaTarget,

  project = nil,
  users = nil,
  keys = nil,
  grants = nil,
  buckets = nil,
  targets = nil,
  anonymous_access = nil,
}

function Mcli:new(o): Mcli
  return Meta:type(o, self, 'Mcli')
end

function Mcli:from(project: Project.Project): Mcli
  assert(project ~= nil)
  return Mcli
    :new({
      project = project,
      users = Meta:array {},
      keys = Meta:array {},
      grants = Meta:array {},
      buckets = Meta:array {},
      targets = Meta:array {},
      anonymous_access = Meta:array {},
    })
end

function Mcli.with_rules(self: Mcli, children: {any}): Mcli
  children = children or {}

  for _, child in children do
    if child.__type == 'User' then
      self.users[#self.users + 1] = child::User.User
    elseif child.__type == 'Key' then
      self.keys[#self.keys + 1] = child::Key.Key
    elseif child.__type == 'Grant' then
      self.grants[#self.grants + 1] = child::Grant.Grant
    elseif child.__type == 'Bucket' then
      self.buckets[#self.buckets + 1] = child::Bucket.Bucket
    elseif child.__type == 'KafkaTarget' then
      self.targets[#self.targets + 1] = child::KafkaTarget.KafkaTarget
    elseif child.__type == 'AnonymousAccess' then
      self.anonymous_access[#self.anonymous_access + 1] = child::string
    end
  end

  return self
end

function Mcli.unwrap(self: Mcli)
  return {
    project = self.project:unwrap_project(),
    users = Wrapper:unwrap_array(self.users),
    keys = Wrapper:unwrap_array(self.keys),
    grants = Wrapper:unwrap_array(self.grants),
    buckets = Wrapper:unwrap_array(self.buckets),
    targets = Wrapper:unwrap_array(self.targets),
    anonymous_access = self.anonymous_access,
  }
end

return Mcli