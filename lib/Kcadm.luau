local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Project = require('@develfish-repo.project/lib/Project')
local Realm = require('@root/lib/kcadm/Realm')
local Client = require('@root/lib/kcadm/Client')
local User = require('@root/lib/kcadm/User')
local Group = require('@root/lib/kcadm/Group')
local Role = require('@root/lib/kcadm/Role')
local Member = require('@root/lib/kcadm/Member')
local Grant = require('@root/lib/kcadm/Grant')

export type Kcadm = {
  project: Project.Project,
  realm: Realm.Realm,
  clients: {Client.Client},
  users: {User.User},
  groups: {Group.Group},
  roles: {Role.Role},
  members: {Member.Member},
  grants: {Grant.Grant},

  with_rules: (self: Kcadm, children: {any}) -> Kcadm,
} & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  project: Project.UnwrappedProject,
  realm: Realm.Unwrapped,
  clients: {Client.Unwrapped},
  users: {User.Unwrapped},
  groups: {Group.Unwrapped},
  roles: {Role.Unwrapped},
  members: {Member.Unwrapped},
  grants: {Grant.Unwrapped},
}

local Kcadm = {
  Realm = Realm,
  Client = Client,
  User = User,
  Group = Group,
  Role = Role,
  Member = Member,
  Grant = Grant,

  project = nil,
  realm = nil,
  clients = nil,
  users = nil,
  groups = nil,
  roles = nil,
  members = nil,
  grants = nil,
}

function Kcadm:new(o): Kcadm
  return Meta:type(o, self, 'Kcadm')
end

function Kcadm:from(project: Project.Project): Kcadm
  assert(project ~= nil)
  return Kcadm
    :new({
      project = project,
      realm = nil,
      clients = Meta:array {},
      users = Meta:array {},
      groups = Meta:array {},
      roles = Meta:array {},
      members = Meta:array {},
      grants = Meta:array {},
    })
end

function Kcadm.with_rules(self: Kcadm, children: {any}): Kcadm
  children = children or {}

  for _, child in children do
    if child.__type == 'Realm' then
      self.realm = child
    elseif child.__type == 'Client' then
      self.clients[#self.clients + 1] = child::Client.Client
    elseif child.__type == 'User' then
      self.users[#self.users + 1] = child::User.User
    elseif child.__type == 'Group' then
      self.groups[#self.groups + 1] = child::Group.Group
    elseif child.__type == 'Role' then
      self.roles[#self.roles + 1] = child::Role.Role
    elseif child.__type == 'Member' then
      self.members[#self.members + 1] = child::Member.Member
    elseif child.__type == 'Grant' then
      self.grants[#self.grants + 1] = child::Grant.Grant
    end
  end

  return self
end

function Kcadm.unwrap(self: Kcadm): Unwrapped
  return {
    project = self.project:unwrap_project(),
    realm = self.realm:unwrap(),
    clients = Wrapper:unwrap_array(self.clients),
    users = Wrapper:unwrap_array(self.users),
    groups = Wrapper:unwrap_array(self.groups),
    roles = Wrapper:unwrap_array(self.roles),
    members = Wrapper:unwrap_array(self.members),
    grants = Wrapper:unwrap_array(self.grants),
  }
end

return Kcadm