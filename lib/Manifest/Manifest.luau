--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local ComposeVolume = require('../Compose/Volume')
local ComposeNetwork = require('../Compose/Network')
local Link = require('./Link')
local DependsOn = require('./DependsOn')
local EnvVariable = require('./EnvVariable')
local Volume = require('./Volume')
local Network = require('./Network')
local Profile = require('./Profile')
local Port = require('./Port')

local Manifest = {
  Link = Link,
  DependsOn = DependsOn,
  EnvVariable = EnvVariable,
  Volume = Volume,
  Network = Network,
  Profile = Profile,
  Port = Port,
}

export type Manifest = typeof(Manifest)

export type ManifestProps = {
  image: string?,
  environment: {EnvVariable.EnvVariable},
  depends_on: {DependsOn.DependsOn},
  links: {Link.Link},
  volumes: {Volume.Volume},
  networks: {Network.Network},
  profiles: {Profile.Profile},
  ports: {Port.Port},
}

export type ManifestImpl = Manifest & ManifestProps

export type AnyChild =
  | Link.Link
  | DependsOn.DependsOn
  | EnvVariable.EnvVariable
  | Volume.Volume
  | Network.Network
  | Profile.Profile
  | Port.Port

export type Environment = {
  [string]: any
}

export type Unwrapped = {
  image: string?,
  environment: Environment?,
  depends_on: {string}?,
  links: {string}?,
  volumes: {string}?,
  networks: {string}?,
  profiles: {string}?,
  ports: {string}?,
}

function Manifest:new(o: ManifestProps): Manifest
  return Meta:type(o, self, 'Manifest')
end

function Manifest:from_empty(): Manifest
  return Manifest:new {
    environment = Meta:array {},
    depends_on = Meta:array {},
    links = Meta:array {},
    volumes = Meta:array {},
    networks = Meta:array {},
    profiles = Meta:array {},
    ports = Meta:array {},
  }
end

function Manifest:setup(children: {AnyChild}): Manifest
  local this = self::ManifestImpl
  children = children or Meta:array {}

  for _, child in children do
    this:with_child(child)
  end

  return this
end

function Manifest:with_child(child: AnyChild): Manifest
  local this = self::ManifestImpl
  local tag = Meta:typeof(child)
  if tag == 'Manifest.Link' then
    this.links[#this.links + 1] = child::Link.Link
  elseif tag == 'Manifest.DependsOn' then
    this.depends_on[#this.depends_on + 1] = child::DependsOn.DependsOn
  elseif tag == 'Manifest.EnvVariable' then
    this.environment[#this.environment + 1] = child::EnvVariable.EnvVariable
  elseif tag == 'Manifest.Volume' then
    this.volumes[#this.volumes + 1] = child::Volume.Volume
  elseif tag == 'Manifest.Network' then
    this.networks[#this.networks + 1] = child::Network.Network
  elseif tag == 'Manifest.Profile' then
    this.profiles[#this.profiles + 1] = child::Profile.Profile
  elseif tag == 'Manifest.Port' then
    this.ports[#this.ports + 1] = child::Port.Port
  end
  return this
end

function Manifest:with_image(image: string?): Manifest
  local this = self::ManifestImpl
  this.image = image
  return this
end

function Manifest:with_env_variable(name: string, value: string?): Manifest
  local this = self::ManifestImpl
  this:with_child(EnvVariable:from(name, value))
  return this
end

function Manifest:with_port(port: string): Manifest
  local this = self::ManifestImpl
  this:with_child(Port:from_string(port))
  return this
end

function Manifest:with_depends_on(service: string): Manifest
  local this = self::ManifestImpl
  this:with_child(DependsOn:from(service))
  return this
end

function Manifest:with_link(service: string, alias: string?): Manifest
  local this = self::ManifestImpl
  this:with_child(Link:from(service, alias))
  return this
end

function Manifest:with_volume_source(source: string, path: string): Manifest
  local this = self::ManifestImpl
  this:with_child(Volume:from_source(source, path))
  return this
end

function Manifest:with_volume_ref(volume: ComposeVolume.Volume, path: string): Manifest
  local this = self::ManifestImpl
  this:with_child(Volume:from_volume(volume, path))
  return this
end

function Manifest:with_network(network: ComposeNetwork.Network): Manifest
  local this = self::ManifestImpl
  this:with_child(Manifest.Network:from(network))
  return this
end

function Manifest:unwrap_volumes(): {string}?
  local this = self::ManifestImpl
  if (#this.volumes == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, v in this.volumes do
    if v.volume ~= nil then
      result[#result + 1] = v.volume.name .. ':' .. v.path
    elseif v.source ~= nil then
      result[#result + 1] = v.source .. ':' .. v.path
    end
  end
  return result
end

function Manifest:unwrap_networks(): {string}?
  local this = self::ManifestImpl
  if (#this.networks == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, n in this.networks do
    result[#result + 1] = n.network.name
  end
  return result
end

function Manifest:unwrap_depends_on(): {string}?
  local this = self::ManifestImpl
  if (#this.depends_on == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, v in this.depends_on do
    result[#result + 1] = v.service
  end
  return result
end

function Manifest:unwrap_links(): {string}?
  local this = self::ManifestImpl
  if (#this.links == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, v in this.links do
    if v.alias == nil then
      result[#result + 1] = v.service
    else
      result[#result + 1] = v.service .. ':' .. v.alias
    end
  end
  return result
end

function Manifest:unwrap_ports(): {string}?
  local this = self::ManifestImpl
  if (#this.ports == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, v in this.ports do
    result[#result + 1] = v.host .. ':' .. v.container
  end
  return result
end

function Manifest:unwrap_profiles(): {string}?
  local this = self::ManifestImpl
  if (#this.profiles == 0) then
    return nil
  end
  local result = Meta:array {}
  for _, v in this.profiles do
    result[#result + 1] = v.name
  end
  return result
end

function Manifest:unwrap_environment(): {[string]: any}?
  local this = self::ManifestImpl
  if (#this.environment == 0) then
    return nil
  end
  local result = Meta:table {}
  for _, v in this.environment do
    result[v.name] = v.value
  end
  return result
end

function Manifest:unwrap(): Unwrapped
  local this = self::ManifestImpl
  return {
    image = this.image,
    environment = this:unwrap_environment(),
    depends_on = this:unwrap_depends_on(),
    links = this:unwrap_links(),
    volumes = this:unwrap_volumes(),
    networks = this:unwrap_networks(),
    profiles = this:unwrap_profiles(),
    ports = this:unwrap_ports(),
  }
end

return Manifest
