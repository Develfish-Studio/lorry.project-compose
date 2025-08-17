--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Manifest = require('../Manifest/Manifest')
local Realm = require('./Realm')
local Client = require('./Client')
local User = require('./User')
local Group = require('./Group')
local Role = require('./Role')
local Member = require('./Member')
local Grant = require('./Grant')
local Remote = require('./Remote')

local Kcadm = {
  Realm = Realm,
  Client = Client,
  User = User,
  Group = Group,
  Role = Role,
  Member = Member,
  Grant = Grant,
  Remote = Remote,
}

export type Kcadm = typeof(Kcadm)

export type KcadmProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
  remote: Remote.Remote?,
  realm: Realm.Realm,
  clients: {Client.Client},
  users: {User.User},
  groups: {Group.Group},
  roles: {Role.Role},
  members: {Member.Member},
  grants: {Grant.Grant},
}

export type KcadmImpl = Kcadm & KcadmProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
    remote: Remote.Unwrapped?,
    realm: Realm.Unwrapped,
    clients: {Client.Unwrapped},
    users: {User.Unwrapped},
    groups: {Group.Unwrapped},
    roles: {Role.Unwrapped},
    members: {Member.Unwrapped},
    grants: {Grant.Unwrapped},
  },
}

export type ConfigurerFunc = (manifest: Manifest.Manifest) -> ()

export type AnyChild =
  | Remote.Remote
  | Realm.Realm
  | Client.Client
  | User.User
  | Group.Group
  | Role.Role
  | Member.Member
  | Grant.Grant
  | Manifest.AnyChild

export type OpenIDClient = {
  client_id: string,
  client_secret: string
}

function Kcadm:new(o: KcadmProps): Kcadm
  return Meta:type(o, self, 'Kcadm')
end

function Kcadm:from(project: Project.Project, name: string, realm: string): Kcadm
  assert(project ~= nil)
  assert(name ~= nil)
  assert(realm ~= nil)
  return Kcadm
    :new({
      project = project,
      name = name,
      realm = Realm:from(realm),
      clients = Meta:array {},
      users = Meta:array {},
      groups = Meta:array {},
      roles = Meta:array {},
      members = Meta:array {},
      grants = Meta:array {},
      manifest = Manifest:from_empty(),
    })
end

function Kcadm:configure(configurer: {ConfigurerFunc}): Kcadm
  local this = self::KcadmImpl
  for _, func in configurer do
    func(this.manifest)
  end
  return this
end

function Kcadm:setup(children: {AnyChild}): Kcadm
  local this = self::KcadmImpl
  children = children or Meta:array {}
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Kcadm:with_child(child: AnyChild): Kcadm
  local this = self::KcadmImpl
  local tag = Meta:typeof(child)
  if tag == 'Kcadm.Remote' then
    this.remote = child::Remote.Remote
  elseif tag == 'Kcadm.Realm' then
    this.realm = child::Realm.Realm
  elseif tag == 'Kcadm.Client' then
    this.clients[#this.clients + 1] = child::Client.Client
  elseif tag == 'Kcadm.User' then
    this.users[#this.users + 1] = child::User.User
  elseif tag == 'Kcadm.Group' then
    this.groups[#this.groups + 1] = child::Group.Group
  elseif tag == 'Kcadm.Role' then
    this.roles[#this.roles + 1] = child::Role.Role
  elseif tag == 'Kcadm.Member' then
    this.members[#this.members + 1] = child::Member.Member
  elseif tag == 'Kcadm.Grant' then
    this.grants[#this.grants + 1] = child::Grant.Grant
  else
    this.manifest:with_child(child::Manifest.AnyChild)
  end
  return this
end

function Kcadm:with_remote(server: string, realm: string, username: string, password: string): Kcadm
  local this = self::KcadmImpl
  this:with_child(Remote:from(server, realm, username, password))
  return this
end

function Kcadm:with_client(openid_client: OpenIDClient): Kcadm
  local this = self::KcadmImpl
  this:with_child(Client:from(openid_client.client_id, openid_client.client_secret))
  return this
end

function Kcadm:with_realm_role(name: string): Kcadm
  local this = self::KcadmImpl
  this:with_child(Role:realm(name))
  return this
end

function Kcadm:with_client_role(client_name: string, name: string): Kcadm
  local this = self::KcadmImpl
  this:with_child(Role:client(client_name, name))
  return this
end

function Kcadm:with_group(name: string): Kcadm
  local this = self::KcadmImpl
  this:with_child(Group:from(name))
  return this
end

function Kcadm:with_user(username: string, password: string): Kcadm
  local this = self::KcadmImpl
  this:with_child(User:from_credentials(username, password))
  return this
end

function Kcadm:with_member(username: string, group: string): Kcadm
  local this = self::KcadmImpl
  this:with_child(Member:from(username, group))
  return this
end

function Kcadm:with_grant(remote: string, role: string): Kcadm
  local this = self::KcadmImpl
  this:with_child(Grant:from(remote, role))
  return this
end

function Kcadm:unwrap(): Unwrapped
  local this = self::KcadmImpl
  return {
    project = this.project:unwrap_project(),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap(),
      remote = Wrapper:unwrap_or_nil(this.remote),
      realm = this.realm:unwrap(),
      clients = Wrapper:unwrap_array(this.clients),
      users = Wrapper:unwrap_array(this.users),
      groups = Wrapper:unwrap_array(this.groups),
      roles = Wrapper:unwrap_array(this.roles),
      members = Wrapper:unwrap_array(this.members),
      grants = Wrapper:unwrap_array(this.grants),
    }
  }
end

return Kcadm
