--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Manifest = require('./Manifest')
local ComposeVolume = require('./compose/Volume')
local ComposeNetwork = require('./compose/Network')
local Realm = require('@root/lib/kcadm/Realm')
local Client = require('@root/lib/kcadm/Client')
local User = require('@root/lib/kcadm/User')
local Group = require('@root/lib/kcadm/Group')
local Role = require('@root/lib/kcadm/Role')
local Member = require('@root/lib/kcadm/Member')
local Grant = require('@root/lib/kcadm/Grant')

local Kcadm = {
  Realm = Realm,
  Client = Client,
  User = User,
  Group = Group,
  Role = Role,
  Member = Member,
  Grant = Grant,
}

export type Kcadm = typeof(Kcadm)

export type KcadmProps = {
  project: Project.Project,
  name: string,
  manifest: Manifest.Manifest,
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
  realm: Realm.Unwrapped,
  clients: {Client.Unwrapped},
  users: {User.Unwrapped},
  groups: {Group.Unwrapped},
  roles: {Role.Unwrapped},
  members: {Member.Unwrapped},
  grants: {Grant.Unwrapped},
  service: {
    name: string,
    manifest: Manifest.Unwrapped,
  },
}

export type AnyChild = Realm.Realm | Client.Client | User.User | Group.Group | Role.Role | Member.Member | Grant.Grant | Manifest.AnyChild

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

function Kcadm:with_grant(target: string, role: string): Kcadm
  local this = self::KcadmImpl
  this:with_child(Grant:from(target, role))
  return this
end

function Kcadm:with_link(service: string, alias: string?): Kcadm
  local this = self::KcadmImpl
  this.manifest:with_child(Manifest.Link:from(service, alias))
  return this
end

function Kcadm:with_depends_on(service: string): Kcadm
  local this = self::KcadmImpl
  this.manifest:with_child(Manifest.DependsOn:from(service))
  return this
end

function Kcadm:with_volume_ref(volume: ComposeVolume.Volume, path: string): Kcadm
  local this = self::KcadmImpl
  this.manifest:with_child(Manifest.Volume:from_volume(volume, path))
  return this
end

function Kcadm:with_volume_source(source: string, path: string): Kcadm
  local this = self::KcadmImpl
  this.manifest:with_child(Manifest.Volume:from_source(source, path))
  return this
end

function Kcadm:with_network(network: ComposeNetwork.Network): Kcadm
  local this = self::KcadmImpl
  this.manifest:with_child(Manifest.Network:from(network))
  return this
end

function Kcadm:with_child(child: AnyChild): Kcadm
  local this = self::KcadmImpl
  local tag = Meta:typeof(child)
  if tag == 'Kcadm.Realm' then
    self.realm = child::Realm.Realm
  elseif tag == 'Kcadm.Client' then
    self.clients[#self.clients + 1] = child::Client.Client
  elseif tag == 'Kcadm.User' then
    self.users[#self.users + 1] = child::User.User
  elseif tag == 'Kcadm.Group' then
    self.groups[#self.groups + 1] = child::Group.Group
  elseif tag == 'Kcadm.Role' then
    self.roles[#self.roles + 1] = child::Role.Role
  elseif tag == 'Kcadm.Member' then
    self.members[#self.members + 1] = child::Member.Member
  elseif tag == 'Kcadm.Grant' then
    self.grants[#self.grants + 1] = child::Grant.Grant
  else
    this.manifest:with_child(child::Manifest.AnyChild)
  end
  return this
end

function Kcadm:setup(children: {AnyChild}): Kcadm
  local this = self::KcadmImpl
  children = children or Meta:array {}

  for _, child in children do
    Kcadm:with_child(child)
  end

  return this
end

function Kcadm:unwrap(): Unwrapped
  local this = self::KcadmImpl
  return {
    project = this.project:unwrap_project(),
    realm = this.realm:unwrap(),
    clients = Wrapper:unwrap_array(this.clients),
    users = Wrapper:unwrap_array(this.users),
    groups = Wrapper:unwrap_array(this.groups),
    roles = Wrapper:unwrap_array(this.roles),
    members = Wrapper:unwrap_array(this.members),
    grants = Wrapper:unwrap_array(this.grants),
    service = {
      name = this.name,
      manifest = this.manifest:unwrap()
    }
  }
end

return Kcadm
